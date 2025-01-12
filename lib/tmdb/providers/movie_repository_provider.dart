import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_date/mock/tmdb/repositories/movie_repository.dart';
import 'package:movie_date/repositories/movie_api_repository.dart';
import 'package:movie_date/repositories/movie_repository.dart';
import 'package:movie_date/tmdb/repositories/movie_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'movie_repository_provider.g.dart';

@riverpod
MovieApiRepository movieApiRepository(Ref ref) {
  final apiKey = dotenv.env['API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    throw Exception("API_KEY is missing or empty in the .env file");
  }
  return TmdbMovieRepository(apiKey);
}

@riverpod
MovieApiRepository mockMovieRepository(Ref ref) {
  return MockTmdbMovieRepository();
}
