import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jp_moviedb/api.dart';
import 'package:jp_moviedb/types/movie.dart';
import 'package:movie_date/utils/constants.dart';

class MovieRepository {
  late TmdbApi api;

  MovieRepository(String apiKey) : api = TmdbApi(apiKey);

  Future<List<Movie>> fetchMoviesWithFilters(dynamic filter) async {
    return await api.discover.getMovies(filter);
  }

  Future<Movie> fetchMovieDetails(Movie movie) async {
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

  Future<List<int>> fetchMovieChoices(String roomId) async {
    var result = await supabase.rpc('getmoviechoices', params: {'room_id': roomId});
    return List<int>.from(jsonDecode(result)).toList();
  }

  Future<List<int>> fetchUsersMovieChoices(String roomId) async {
    var result = await supabase.rpc('getusersmoviechoices', params: {'room_id': roomId});
    return result != null ? List<int>.from(jsonDecode(result)) : [];
  }
}
