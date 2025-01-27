import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_date/api/api.dart';
import 'package:movie_date/api/types/movie.dart';
import 'package:movie_date/models/movie2_model.dart';
import 'package:movie_date/models/watch_options.dart';
import 'package:movie_date/repositories/movie_repository.dart';
import 'package:movie_date/utils/constants.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:movie_date/utils/conversion.dart';


class TmdbMovieRepository implements MovieRepository {
  late TmdbApi api;

  TmdbMovieRepository(String apiKey) : api = TmdbApi(apiKey);

  Future<List<Movie>> getMoviesWithFilters(dynamic filter) async {
    return await api.discover.getMovies(filter);
  }

  Future<Movie> getMovieDetails(Movie movie) async {
    return await api.discover.getMovieDetails(movie);
  }

  Future<Movie> getMovie(int movieId) async {
    await dotenv.load();
    api = TmdbApi(
      dotenv.env['API_KEY']!,
    );
    Movie movie = Movie(title: '', overview: '', releaseDate: DateTime.now(), id: movieId);
    return await api.discover.getMovieDetails(movie);
  }

  Future<void> saveMovie(int movieId, String profileId, String roomId) async {
    await supabase.from('moviechoices').upsert({
      'profile_id': profileId,
      'movie_id': movieId,
      'room_id': roomId,
    });
  }

  Map<int, int> getMovieCounts(List<int> movieIds) {
    return groupBy(movieIds, (int movieId) => movieId).map((key, value) => MapEntry(key, value.length));
  }

  Future<Map<int, int>> getMovieChoices(String roomId) async {
    var result = await supabase
        .from('moviechoices')
        .select('movie_id')
        .eq('room_id', roomId)
        .neq('profile_id', supabase.auth.currentUser!.id);
    List<int> list = result.map<int>((item) => (item as Map<String, dynamic>)['movie_id'] as int).toList();
    Map<int, int> movieCounts = getMovieCounts(list);
    return movieCounts;
  }

  Future<Map<int, int>> getUsersMovieChoices(String roomId) async {
    var result = await supabase
        .from('moviechoices')
        .select('movie_id')
        .eq('room_id', roomId)
        .eq('profile_id', supabase.auth.currentUser!.id);
    List<int> list = result.map<int>((item) => (item as Map<String, dynamic>)['movie_id'] as int).toList();
    Map<int, int> movieCounts = getMovieCounts(list);
    return movieCounts;
  }

  Future<void> deleteMovieChoicesByRoomId(String roomId) async {
    await supabase.from('moviechoices').delete().eq('room_id', roomId).eq('profile_id', supabase.auth.currentUser!.id);
  }

  @override
  Future<List<WatchOption>> getMovieWatchOptions(int movieId) async {
    final dio = Dio();
    await dotenv.load();
    var apiKey = dotenv.env['WHERE_TO_WATCH_API'];
    final response = await dio.get(
      'https://streaming-availability.p.rapidapi.com/shows/movie/$movieId',
      queryParameters: {
        'output_language': 'en',
        'country': 'us',
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': null,
          'x-rapidapi-ua': 'RapidAPI-Playground',
          'x-rapidapi-key': apiKey,
          'x-rapidapi-host': 'streaming-availability.p.rapidapi.com',
        },
      ),
    );

    if (response.statusCode == 200) {
      List<WatchOption> watchOptions = [];
      if (response.data['streamingOptions'] != null && response.data['streamingOptions']['us'] != null) {
        for (var option in response.data['streamingOptions']['us']) {
          var watchOption = WatchOption.fromJson(option);
          if (!watchOptions.any((o) => o.serviceName == watchOption.serviceName)) {
            watchOptions.add(watchOption);
          }
        }
      }

      return watchOptions;
    } else {
      throw Exception('Failed to load movie watch options');
    }
  }

  @override
  Future<List<Movie>> getTopMoviesByStreamingService(String service) async {
    final dio = Dio();
    await dotenv.load();
    var apiKey = dotenv.env['WHERE_TO_WATCH_API'];
    final response = await dio.get(
      'https://streaming-availability.p.rapidapi.com/shows/top',
      queryParameters: {
        'output_language': 'en',
        'country': 'us',
        'service': service,
        'show_type': 'movie',
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': null,
          'x-rapidapi-ua': 'RapidAPI-Playground',
          'x-rapidapi-key': apiKey,
          'x-rapidapi-host': 'streaming-availability.p.rapidapi.com',
        },
      ),
    );

    if (response.statusCode == 200) {
      List<Movie> movies = [];
      if (response.data != null) {
        for (var m in response.data) {
          var movie2 = Movie2.fromJson(m);
          movies.add(ConversionUtils.toMovie(movie2));
        }
      }

      return movies;
    } else {
      throw Exception('Failed to load movie watch options');
    }
  }
}
