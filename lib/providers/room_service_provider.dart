import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/providers/members_repository_provider.dart';
import 'package:movie_date/providers/profile_repository_provider.dart';
import 'package:movie_date/providers/room_repository_provider.dart';
import 'package:movie_date/services/room_service.dart';

final roomServiceProvider = Provider<RoomService>((ref) {
  final roomRepository = ref.read(roomRepositoryProvider);
  final membersRepository = ref.read(membersRepositoryProvider);
  final profileRepository = ref.read(profileRepositoryProvider);

  return RoomService(roomRepository, membersRepository, profileRepository);
});
