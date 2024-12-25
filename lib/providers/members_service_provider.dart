import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/providers/members_repository_provider.dart';
import 'package:movie_date/providers/profile_repository_provider.dart';
import 'package:movie_date/providers/room_repository_provider.dart';
import 'package:movie_date/services/member_service.dart';

final membersServiceProvider = Provider<MemberService>((ref) {
  final roomRepository = ref.read(roomRepositoryProvider);
  final membersRepository = ref.read(membersRepositoryProvider);
  final profileRepository = ref.read(profileRepositoryProvider);

  return MemberService(roomRepository, membersRepository, profileRepository);
});
