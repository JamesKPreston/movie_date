import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/repositories/login_repository.dart';
import 'package:movie_date/supabase/repositories/login_repository.dart';

final loginRepositoryProvider = Provider<LoginRepository>((ref) {
  return SupabaseLoginRepository();
});
