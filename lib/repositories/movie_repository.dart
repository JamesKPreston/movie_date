import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jp_moviedb/api.dart';
import 'package:jp_moviedb/types/movie.dart';
import 'package:movie_date/utils/constants.dart';
import 'package:collection/collection.dart';

class MovieRepository {
  late TmdbApi api;

  MovieRepository(String apiKey) : api = TmdbApi(apiKey);

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
}
