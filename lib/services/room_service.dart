import 'package:movie_date/models/room.dart';
import 'package:movie_date/utils/constants.dart';

class RoomService {
  Future<Room> getRoom() async {
    // Fetch rooms from the server
    var result = await supabase.from('rooms').select();
    Room room = Room.fromMap(result[0]);
    return room;
  }

  Future<void> addRoom(Room room) async {
    // Add room to the server
  }

  Future<void> deleteRoom(Room room) async {
    // Delete room from the server
  }

  Future<void> updateRoom(Room room) async {
    // Update room on the server
  }
}
