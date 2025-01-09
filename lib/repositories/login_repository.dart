abstract class LoginRepository {
  Future<void> login(String email, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
}