import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_date/repositories/genre_repository.dart';
import 'package:movie_date/tmdb/repositories/genre_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'genre_repository_provider.g.dart';

@riverpod
GenreRepository genreRepository(Ref ref) {
  final apiKey = dotenv.env['API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    throw Exception("API_KEY is missing or empty in the .env file");
  }
  return TmdbGenreRepository(apiKey);
}
