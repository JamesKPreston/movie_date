import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

const preloader = Center(child: CircularProgressIndicator(color: Colors.orange));

const formSpacer = SizedBox(width: 16, height: 16);

const formPadding = EdgeInsets.symmetric(vertical: 20, horizontal: 16);

const unexpectedErrorMessage = 'Unexpected error occurred.';

final List<Map<String, dynamic>> services = [
  {"label": "Any", "value": "any", "id": "0", "image": "assets/movieDate.png"},
  {"label": "Tubi", "value": "tubi", "id": "73", "image": "assets/icons/tubi.png"},
  {"label": "Amazon Prime", "value": "prime", "id": "9", "image": "assets/icons/prime.png"},
  {"label": "Netflix", "value": "netflix", "id": "8", "image": "assets/icons/netflix.png"},
  {"label": "Hulu", "value": "hulu", "id": "15", "image": "assets/icons/hulu.png"},
  {"label": "HBO Max", "value": "hbo", "id": "1899", "image": "assets/icons/max.png"},
  {"label": "Apple TV", "value": "apple", "id": "350", "image": "assets/icons/apple.png"},
  {"label": "Disney+", "value": "disney", "id": "337", "image": "assets/icons/disney.png"},
  {"label": "Paramount+", "value": "paramount", "id": "531,1770,1853", "image": "assets/icons/paramount.png"},
  {"label": "Peacock", "value": "peacock", "id": "386", "image": "assets/icons/peacock.png"},
];

final appTheme = ThemeData.light().copyWith(
  primaryColorDark: Colors.orange,
  appBarTheme: const AppBarTheme(
    elevation: 1,
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 18,
    ),
  ),
  primaryColor: Colors.orange,
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.orange,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.orange,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    floatingLabelStyle: const TextStyle(
      color: Colors.orange,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.grey,
        width: 2,
      ),
    ),
    focusColor: Colors.orange,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.orange,
        width: 2,
      ),
    ),
  ),
);

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }
}
