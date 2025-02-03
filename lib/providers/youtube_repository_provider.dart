import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/repositories/youtube_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'youtube_repository_provider.g.dart';

@riverpod
YouTubeRepository youTubeRepository(Ref ref) {
  final apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    throw Exception("YOUTUBE_API_KEY is missing or empty in the .env file");
  }
  return YouTubeRepository(apiKey);
}
