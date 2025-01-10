import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/providers/members_repository_provider.dart';
import 'package:movie_date/providers/profile_repository_provider.dart';
import 'package:movie_date/providers/room_repository_provider.dart';
import 'package:movie_date/services/room_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'room_service_provider.g.dart';

@riverpod
RoomService roomService(Ref ref) {
  final roomRepository = ref.read(roomRepositoryProvider);
  final membersRepository = ref.read(membersRepositoryProvider);
  final profileRepository = ref.read(profileRepositoryProvider);

  return RoomService(roomRepository, membersRepository, profileRepository);
}
