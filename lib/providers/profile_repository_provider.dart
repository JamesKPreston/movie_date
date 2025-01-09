import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/repositories/profile_repository.dart';
import 'package:movie_date/supabase/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return SupabaseProfileRepository();
});
