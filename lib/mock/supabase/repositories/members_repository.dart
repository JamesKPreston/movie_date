import 'package:movie_date/models/member_model.dart';
import 'package:movie_date/repositories/members_repository.dart';

class SupabaseMembersRepository implements MembersRepository {
  Future<List<String>> getRoomMembers(String roomId) async {
    throw UnimplementedError();
  }

  Future<void> addMember(Member member) async {
    throw UnimplementedError();
  }

  Future<String> getRoomIdByUserId(String userId) async {
    throw UnimplementedError();
  }
}
