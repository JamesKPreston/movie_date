import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/repositories/login_repository.dart';

class LoginNotifier extends StateNotifier<bool> {
  final LoginRepository _loginRepository;
  bool isLoading = false;

  LoginNotifier(this._loginRepository) : super(false);

  Future<void> login(String email, String password) async {
    try {
      await _loginRepository.login(email, password);
      state = await _loginRepository.isLoggedIn();
    } catch (e) {
      state = false;
      throw Exception('Login failed: $e');
    } finally {
      isLoading = false;
      state = state;
    }
  }

  Future<void> logout() async {
    try {
      await _loginRepository.logout();
      state = false;
    } catch (e) {
      rethrow;
    }
  }
}
