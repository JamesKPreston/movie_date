import 'package:movie_date/models/member_model.dart';

abstract class MembersRepository {
  Future<List<String>> getRoomMembers(String roomId);
  Future<void> addMember(Member member);
  Future<String> getRoomIdByUserId(String userId);
}
