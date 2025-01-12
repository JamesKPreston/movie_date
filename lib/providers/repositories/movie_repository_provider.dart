import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_date/mock/tmdb/repositories/movie_repository.dart';
import 'package:movie_date/repositories/movie_repository.dart';
import 'package:movie_date/supabase/repositories/movie_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'movie_repository_provider.g.dart';

@riverpod
MovieRepository movieRepository(Ref ref) {
  return SupabaseMovieRepository();
}
