import 'package:jp_moviedb/types/movie.dart';

abstract class MovieApiRepository {
  Future<List<Movie>> getMoviesWithFilters(dynamic filter);
  Future<Movie> getMovieDetails(Movie movie);
  Future<Movie> getMovie(int movieId);
}
