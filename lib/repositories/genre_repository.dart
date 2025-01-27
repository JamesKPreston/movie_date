import 'package:movie_date/api/types/genre.dart';

abstract class GenreRepository {
  Future<List<Genre>> getGenres();
  Future<String> getGenreNames(List<int> genreIds);
}
