import 'package:jp_moviedb/types/genre.dart';
import 'package:movie_date/repositories/genre_repository.dart';

class MockTmdbGenreRepository implements GenreRepository {
  Future<List<Genre>> getGenres() async {
    throw UnimplementedError();
  }

  Future<String> getGenreNames(List<int> genreIds) async {
    throw UnimplementedError();
  }
}
