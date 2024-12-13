import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/repositories/movie_repository.dart';

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepository();
});
