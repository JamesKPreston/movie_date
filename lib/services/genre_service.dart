import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jp_moviedb/api.dart';
import 'package:jp_moviedb/types/genre.dart';

class GenreService {
  late TmdbApi api;
  List<Genre> genres = [];
  int count = 0;
  Future<List<Genre>> getGenres() async {
    // Fetch movies from the network
    await dotenv.load();
    api = TmdbApi(
      dotenv.env['API_KEY']!,
    );

    genres.clear();

    var result = await api.genres.getGenres();
    return result;
  }
}
