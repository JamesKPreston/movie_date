import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/repositories/members_repository.dart';

final membersRepositoryProvider = Provider<MembersRepository>((ref) {
  return MembersRepository();
});
