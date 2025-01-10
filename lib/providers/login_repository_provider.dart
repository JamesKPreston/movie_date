import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/repositories/login_repository.dart';
import 'package:movie_date/supabase/repositories/login_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_repository_provider.g.dart';

@riverpod
LoginRepository loginRepository(Ref ref) {
  return SupabaseLoginRepository();
}
