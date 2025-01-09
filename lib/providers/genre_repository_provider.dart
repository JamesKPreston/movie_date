import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_date/repositories/genre_repository.dart';
import 'package:movie_date/repositories/supabase/supabase_genre_repository.dart';

final genreRepositoryProvider = Provider<GenreRepository>((ref) {
  final apiKey = dotenv.env['API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    throw Exception("API_KEY is missing or empty in the .env file");
  }
  return TmdbGenreRepository(apiKey);
});
