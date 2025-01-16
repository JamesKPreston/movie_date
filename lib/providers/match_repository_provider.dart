import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/repositories/match_repository.dart';
import 'package:movie_date/supabase/repositories/match_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'match_repository_provider.g.dart';

@riverpod
MatchRepository matchRepository(Ref ref) {
  return SupabaseMatchRepository();
}
