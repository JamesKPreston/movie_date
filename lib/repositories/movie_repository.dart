import 'package:jp_moviedb/types/movie.dart';
import 'package:movie_date/models/watch_options.dart';

abstract class MovieRepository {
  Future<List<Movie>> getMoviesWithFilters(dynamic filter);
  Future<Movie> getMovieDetails(Movie movie);
  Future<Movie> getMovie(int movieId);
  Future<void> saveMovie(int movieId, String profileId, String roomId);
  Map<int, int> getMovieCounts(List<int> movieIds);
  Future<Map<int, int>> getMovieChoices(String roomId);
  Future<Map<int, int>> getUsersMovieChoices(String roomId);
  Future<void> deleteMovieChoicesByRoomId(String roomId);
  Future<List<WatchOption>> getMovieWatchOptions(int movieId);
}
