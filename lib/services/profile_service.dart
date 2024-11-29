import 'package:movie_date/models/profile.dart';
import 'package:movie_date/utils/constants.dart';

class ProfileService {
  Future<String> getRoomIdByUsername(String username) async {
    // Fetch profile from the server
    var result = await supabase.from('profiles').select('room_id').eq('username', username).single();

    return result['room_id'] as String;
  }

  Future<String> getUsernameById(String id) async {
    // Fetch profile from the server
    var result = await supabase.from('profiles').select('username').eq('id', id).single();

    return result['username'] as String;
  }

  Future<void> updateProfile(Profile profile) async {
    // Update room on the server
  }
}
