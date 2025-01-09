import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/notifier/login_notifier.dart';
import 'package:movie_date/providers/login_repository_provider.dart';

final loginNotifierProvider = StateNotifierProvider<LoginNotifier, bool>((ref) {
  final loginRepository = ref.read(loginRepositoryProvider);
  return LoginNotifier(loginRepository);
});
