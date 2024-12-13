import 'package:jp_moviedb/api.dart';
import 'package:jp_moviedb/types/genre.dart';

class GenreRepository {
  final TmdbApi api;

  GenreRepository(String apiKey) : api = TmdbApi(apiKey);

  Future<List<Genre>> getGenres() async {
    return await api.genres.getGenres();
  }
}