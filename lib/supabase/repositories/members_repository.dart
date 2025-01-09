import 'package:movie_date/models/member_model.dart';
import 'package:movie_date/repositories/members_repository.dart';
import 'package:movie_date/utils/constants.dart';

class SupabaseMembersRepository implements MembersRepository {
  Future<List<String>> getRoomMembers(String roomId) async {
    try {
      var result = await supabase.from('members').select('email').eq('room_id', roomId) as List<dynamic>;
      if (result.isNotEmpty) {
        return result.map((item) => item['email'] as String).toList();
      } else {
        throw Exception('Room id not found or no members in the room');
      }
    } catch (e) {
      throw Exception('Failed to fetch room members: $e');
    }
  }

  Future<void> addMember(Member member) async {
    try {
      await supabase.from('members').upsert(member.toJson());
    } catch (e) {
      throw Exception('Failed to add member: $e');
    }
  }

  Future<String> getRoomIdByUserId(String userId) async {
    try {
      var result =
          await supabase.from('members').select('room_id').eq('user_id', userId).single() as Map<String, dynamic>;

      if (result.isNotEmpty) {
        return result['room_id'] as String;
      } else {
        throw Exception('User id not found or no room code associated with the user');
      }
    } catch (e) {
      throw Exception('Failed to fetch room code: $e');
    }
  }
}
