import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/providers/movie_repository_provider.dart';
import 'package:movie_date/providers/profile_repository_provider.dart';
import 'package:movie_date/providers/room_service_provider.dart';
import 'package:movie_date/services/movie_service.dart';

final movieServiceProvider = Provider<MovieService>((ref) {
  final profileRepo = ref.read(profileRepositoryProvider);
  final movieRepo = ref.read(movieRepositoryProvider);
  final roomService = ref.read(roomServiceProvider);

  return MovieService(movieRepo, profileRepo, roomService);
});
