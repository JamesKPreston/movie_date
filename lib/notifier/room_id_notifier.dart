import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/services/profile_service.dart';
import 'package:movie_date/utils/constants.dart';

class RoomIdNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    final roomCode = await ProfileService().getRoomCodeById(user.id);
    return ProfileService().getRoomIdByRoomCode(roomCode);
  }

  // Update the room ID and notify listeners
  Future<void> updateRoomId(String newRoomId) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    await ProfileService().updateProfileRoomId(newRoomId);

    // Update the state to reflect the new room ID
    state = AsyncData(newRoomId);
  }
}
