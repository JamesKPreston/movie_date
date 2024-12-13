import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/providers/profile_repository_provider.dart';
import 'package:movie_date/utils/constants.dart';

class RoomIdNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    final profileRepo = ref.read(profileRepositoryProvider);

    final roomCode = await profileRepo.getRoomCodeById(user.id);
    return profileRepo.getRoomIdByRoomCode(roomCode);
  }

  // Update the room ID and notify listeners
  Future<void> updateRoomId(String newRoomId) async {
    final user = supabase.auth.currentUser;
    final profileRepo = ref.read(profileRepositoryProvider);
    if (user == null) {
      throw Exception('User not authenticated');
    }
    await profileRepo.updateProfileRoomId(newRoomId);

    // Update the state to reflect the new room ID
    state = AsyncData(newRoomId);
  }
}
