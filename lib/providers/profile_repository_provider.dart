import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/repositories/profile_repository.dart';
import 'package:movie_date/supabase/repositories/profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository_provider.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return SupabaseProfileRepository();
}
