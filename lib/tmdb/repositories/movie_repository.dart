import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jp_moviedb/api.dart';
import 'package:jp_moviedb/types/movie.dart';
import 'package:movie_date/repositories/movie_api_repository.dart';

class TmdbMovieRepository implements MovieApiRepository {
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
}
