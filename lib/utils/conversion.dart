import 'package:movie_date/api/types/movie.dart';
import 'package:movie_date/models/movie2_model.dart';

class ConversionUtils {
  static Movie toMovie(Movie2 movie2) {
    return Movie(
      title: movie2.title,
      posterPath: movie2.posterPath,
      overview: movie2.overview,
      releaseDate: DateTime(movie2.releaseYear),
      id: int.parse(movie2.id),
      originalTitle: movie2.originalTitle,
      runtime: movie2.runtime,
    );
  }
}
