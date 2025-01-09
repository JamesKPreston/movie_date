import 'package:movie_date/repositories/login_repository.dart';
import 'package:movie_date/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseLoginRepository implements LoginRepository {
  @override
  Future<void> login(String username, String password) async {
    try {
      await supabase.auth.signInWithPassword(email: username, password: password);
    } on AuthException catch (_) {
      rethrow;
    } catch (_) {
      throw Exception("Unexpected error occurred.");
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return supabase.auth.currentUser != null;
  }
}
