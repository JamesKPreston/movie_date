import 'package:movie_date/providers/repositories/login_repository_provider.dart';
import 'package:movie_date/providers/repositories/profile_repository_provider.dart';
import 'package:movie_date/providers/services/room_service_provider.dart';
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

  Future<void> signUp(String email, String password) async {
    try {
      state = const AsyncLoading();
      final userId = await _loginRepository.signUp(email, password);
      state = await AsyncValue.guard(() async {
        await createNewUser(userId, email);
      });
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }

  Future<void> createNewUser(String userId, String email) async {
    try {
      final roomService = ref.read(roomServiceProvider);
      final profileRepo = ref.read(profileRepositoryProvider);
      state = const AsyncLoading();
      await roomService.createRoom(userId, email);
      await profileRepo.updateEmailById(userId, email);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}
