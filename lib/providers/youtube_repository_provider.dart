import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/repositories/youtube_repository.dart';

final youTubeRepositoryProvider = Provider<YouTubeRepository>((ref) {
  return YouTubeRepository();
});
