import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/repositories/room_repository.dart';
import 'package:movie_date/supabase/repositories/room_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'room_repository_provider.g.dart';

@riverpod
RoomRepository roomRepository(Ref ref) {
  return SupabaseRoomRepository();
}
