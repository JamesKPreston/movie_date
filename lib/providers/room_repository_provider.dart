import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/repositories/room_repository.dart';
import 'package:movie_date/repositories/supabase/supabase_room_repository.dart';

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return SupabaseRoomRepository();
});
