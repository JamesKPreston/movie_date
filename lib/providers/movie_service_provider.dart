import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/providers/match_repository_provider.dart';
import 'package:movie_date/providers/members_repository_provider.dart';
import 'package:movie_date/providers/profile_repository_provider.dart';
import 'package:movie_date/providers/room_repository_provider.dart';
import 'package:movie_date/services/movie_service.dart';
import 'package:movie_date/tmdb/providers/movie_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'movie_service_provider.g.dart';

@riverpod
MovieService movieService(Ref ref) {
  final profileRepo = ref.read(profileRepositoryProvider);
  final movieRepo = ref.read(movieRepositoryProvider);
  final roomRepository = ref.read(roomRepositoryProvider);
  final membersRepository = ref.read(membersRepositoryProvider);
  final matchRepository = ref.read(matchRepositoryProvider);
  return MovieService(movieRepo, profileRepo, roomRepository, membersRepository, matchRepository);
}
