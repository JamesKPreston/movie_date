import 'package:movie_date/utils/constants.dart';

class ProfileService {
  Future<String> getRoomIdByRoomCode(String room_code) async {
    // Fetch profile from the server
    var result = await supabase.from('profiles').select('room_id').eq('room_code', room_code);
    if (result != null) {
      return result[0]['room_id'] as String;
    }
    {
      throw Exception('Room code did not match');
    }
  }

  Future<String> getRoomIdById(String id) async {
    // Fetch profile from the server
    var result = await supabase.from('profiles').select('room_id').eq('id', id);
    if (result != null) {
      return result[0]['room_id'] as String;
    }
    {
      throw Exception('Room code not found');
    }
  }

  Future<String> getRoomCodeById(String id) async {
    // Fetch profile from the server
    var result = await supabase.from('profiles').select('room_code').eq('id', id).single();

    return result['room_code'] as String;
  }

  Future<void> updateProfileRoomId(String roomId) async {
    // Update room on the server
    final user = supabase.auth.currentUser;
    await supabase.from('profiles').update({'room_id': roomId}).eq('id', user!.id);
  }

  //currently roomcode is called username in the database but this will change eventually
  Future<void> updateProfileRoomCode(String room_code) async {
    // Update room on the server
    final user = supabase.auth.currentUser;
    await supabase.from('profiles').update({'room_code': room_code}).eq('id', user!.id);
  }
}
