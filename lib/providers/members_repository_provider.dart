import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/repositories/members_repository.dart';
import 'package:movie_date/supabase/repositories/members_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'members_repository_provider.g.dart';

@riverpod
MembersRepository membersRepository(Ref ref) {
  return SupabaseMembersRepository();
}
