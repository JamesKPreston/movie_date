// StateNotifier to handle login state and logic
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/pages/main_page.dart';
import 'package:movie_date/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginNotifier extends StateNotifier<bool> {
  LoginNotifier() : super(false);

  Future<void> signIn(BuildContext context, String email, String password) async {
    state = true; // Set loading state
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      Navigator.of(context).pushAndRemoveUntil(MainPage.route(), (route) => false);
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: "Unexpected error occurred.");
    } finally {
      state = false; // Reset loading state
    }
  }
}
