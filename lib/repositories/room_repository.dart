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

  Future<void> deleteRoom(Room room) async {}

  Future<void> updateRoom(Room room) async {}
}
