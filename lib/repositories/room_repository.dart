import 'package:movie_date/models/room_model.dart';
import 'package:movie_date/utils/constants.dart';

class RoomRepository {
  Future<Room> getRoomByRoomId(String id) async {
    var result = await supabase.from('rooms').select().eq('id', id).single();

    return Room.fromMap(result);
  }

  Future<String> addRoom(Room room) async {
    var result = await supabase.from('rooms').insert(room.toJson()).select('id').single();
    return result['id'] as String;
  }

  Future<String> getRoomCodeById(String id) async {
    var result = await supabase.from('rooms').select('room_code').eq('id', id).single();
    return result['room_code'] as String;
  }

  Future<String> getRoomIdByRoomCode(String roomCode) async {
    var result = await supabase.from('rooms').select('id').eq('room_code', roomCode).single();
    return result['id'] as String;
  }

  Future<void> deleteRoom(Room room) async {}

  Future<void> updateRoom(Room room) async {}
}
