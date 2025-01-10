import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/repositories/youtube_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'youtube_repository_provider.g.dart';

@riverpod
YouTubeRepository youTubeRepository(Ref ref) {
  return YouTubeRepository();
}
