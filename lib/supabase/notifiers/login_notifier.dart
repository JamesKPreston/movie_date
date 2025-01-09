// // StateNotifier to handle login state and logic
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:movie_date/notifier/login_notifier.dart';
// import 'package:movie_date/pages/splash_page.dart';
// import 'package:movie_date/utils/constants.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class SupabaseLoginNotifier extends StateNotifier<bool> implements LoginNotifier {
//   SupabaseLoginNotifier() : super(false);

//   Future<String> signIn(String user, String password) async {
//     try {
//       await supabase.auth.signInWithPassword(email: user, password: password);
//       return "Sign in successful";
//     } on AuthException catch (error) {
//       return error.message;
//     } catch (_) {
//       return "Unexpected error occurred.";
//     }
//   }

//   Future<String> signOut() async {
//     try {
//       await supabase.auth.signOut();
//       return "Sign out successful";
//     } on AuthException catch (error) {
//       return error.message;
//     } catch (_) {
//       return "Unexpected error occurred.";
//     }
//   }
// }
