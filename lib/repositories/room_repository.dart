import 'package:movie_date/models/room_model.dart';

abstract class RoomRepository {
  Future<Room> getRoomByRoomId(String id);
  Future<void> addRoom(Room room);
  Future<String> getRoomCodeById(String id);
  Future<String> getRoomIdByRoomCode(String roomCode);
  Future<void> deleteRoom(Room room);
  Future<void> updateRoom(Room room);
}
