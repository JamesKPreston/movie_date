import 'package:movie_date/providers/login_repository_provider.dart';
import 'package:movie_date/repositories/login_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  late final LoginRepository _loginRepository;

  @override
  FutureOr<void> build() {
    _loginRepository = ref.read(loginRepositoryProvider);
  }

  Future<void> login(String email, String password) async {
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        await _loginRepository.login(email, password);
      });
      state = await AsyncValue.guard(_loginRepository.isLoggedIn);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> logout() async {
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(_loginRepository.logout);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  Future<String> signUp(String email, String password) async {
    try {
      state = const AsyncLoading();
      final userId = await _loginRepository.signUp(email, password);
      state = const AsyncValue.data(null);
      return userId;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }
}
