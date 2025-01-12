import 'package:movie_date/repositories/login_repository.dart';

class MockSupabaseLoginRepository implements LoginRepository {
  @override
  Future<void> login(String username, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {
    throw UnimplementedError();
  }

  @override
  Future<bool> isLoggedIn() async {
    throw UnimplementedError();
  }

  @override
  Future<String> signUp(String email, String password) async {
    throw UnimplementedError();
  }
}
