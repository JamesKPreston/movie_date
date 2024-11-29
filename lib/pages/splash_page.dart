import 'package:flutter/material.dart';
import 'package:movie_date/pages/swipe_page.dart';
import 'package:movie_date/pages/register_page.dart';
import 'package:movie_date/utils/constants.dart';

/// Page to redirect users to the appropriate page depending on the initial auth state
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // await for for the widget to mount
    await Future.delayed(Duration.zero);

    final session = supabase.auth.currentSession;
    if (session == null) {
      Navigator.of(context).pushAndRemoveUntil(RegisterPage.route(), (route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(SwipePage.route(), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: preloader);
  }
}
