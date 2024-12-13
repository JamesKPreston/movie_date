import 'package:movie_date/utils/constants.dart';

class ProfileService {
  Future<String> getRoomIdByRoomCode(String room_code) async {
    var result = await supabase.from('profiles').select('room_id').eq('room_code', room_code);
    if (result != null) {
      return result[0]['room_id'] as String;
    }
    {
      throw Exception('Room code did not match');
    }
  }

  Future<String> getRoomIdById(String id) async {
    var result = await supabase.from('profiles').select('room_id').eq('id', id);
    if (result != null) {
      return result[0]['room_id'] as String;
    }
    {
      throw Exception('Room code not found');
    }
  }

  Future<String> getRoomCodeById(String id) async {
    var result = await supabase.from('profiles').select('room_code').eq('id', id).single();

    return result['room_code'] as String;
  }

  Future<void> updateProfileRoomId(String roomId) async {
    final user = supabase.auth.currentUser;
    await supabase.from('profiles').update({'room_id': roomId}).eq('id', user!.id);
  }

  Future<void> updateProfileRoomCode(String room_code) async {
    final user = supabase.auth.currentUser;
    await supabase.from('profiles').update({'room_code': room_code}).eq('id', user!.id);
  }
}
