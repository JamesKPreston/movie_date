import 'package:jp_moviedb/filters/movie.dart';
import 'package:movie_date/models/member_model.dart';
import 'package:movie_date/models/room_model.dart';
import 'package:movie_date/repositories/members_repository.dart';
import 'package:movie_date/repositories/profile_repository.dart';
import 'package:movie_date/repositories/room_repository.dart';
import 'package:random_string/random_string.dart';
import 'package:uuid/uuid.dart';

class MemberService {
  final RoomRepository _roomRepository;
  final MembersRepository _membersRepository;
  final ProfileRepository _profileRepository;

  MemberService(this._roomRepository, this._membersRepository, this._profileRepository);

  Future<void> createRoom(String userId, String email) async {
    var roomCode = randomAlphaNumeric(6).toUpperCase();
    List<MovieFilters> filters = [];
    MovieFilters filter = MovieFilters(
      page: 1,
    );

    filter.language = 'en';
    filters.add(filter);

    var room = Room(
      id: Uuid().v4(),
      filters: filters,
      room_code: roomCode,
    );

    var roomId = await _roomRepository.addRoom(room);
    var member = Member(
      id: userId,
      room_id: roomId,
      user_id: userId,
      email: email,
    );

    await _membersRepository.addMember(member);
  }

  Future<void> createNewUser(String userId, String email) async {
    await createRoom(userId, email);

    await _profileRepository.updateEmailById(userId, email);
  }

  Future<String> getRoomCodeById(String id) async {
    return _membersRepository.getRoomIdByUserId(id).then((roomId) {
      return _roomRepository.getRoomCodeById(roomId);
    }).catchError((e) {
      throw Exception('Failed to get room code: $e');
    });
  }

  Future<Room> getRoomByUserId(String userId) async {
    try {
      return _membersRepository.getRoomIdByUserId(userId).then((roomId) {
        return _roomRepository.getRoomByRoomId(roomId);
      });
    } catch (e) {
      throw Exception('Failed to get room: $e');
    }
  }

  Future<void> joinRoom(String roomCode, String userId) async {
    try {
      final roomId = await _roomRepository.getRoomIdByRoomCode(roomCode);
      final email = await _profileRepository.getEmailById(userId);
      var member = Member(id: userId, room_id: roomId, user_id: userId, email: email);
      await _membersRepository.addMember(member);
    } catch (e) {
      throw Exception('Failed to join room: $e');
    }
  }

  Future<void> updateRoom(Room room) async {
    try {
      await _roomRepository.updateRoom(room);
    } catch (e) {
      throw Exception('Failed to update room: $e');
    }
  }
}
