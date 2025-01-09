import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/providers/members_repository_provider.dart';
import 'package:movie_date/providers/tmdb/movie_repository_provider.dart';
import 'package:movie_date/providers/profile_repository_provider.dart';
import 'package:movie_date/providers/room_repository_provider.dart';
import 'package:movie_date/services/movie_service.dart';

final movieServiceProvider = Provider<MovieService>((ref) {
  final profileRepo = ref.read(profileRepositoryProvider);
  final movieRepo = ref.read(movieRepositoryProvider);
  final roomRepository = ref.read(roomRepositoryProvider);
  final membersRepository = ref.read(membersRepositoryProvider);

  return MovieService(movieRepo, profileRepo, roomRepository, membersRepository);
});
