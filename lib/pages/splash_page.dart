import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/pages/login_page.dart';
import 'package:movie_date/pages/main_page.dart';
import 'package:movie_date/pages/swipe_page_tutorial.dart';
import 'package:movie_date/providers/repositories/login_repository_provider.dart';
import 'package:movie_date/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Page to redirect users to the appropriate page depending on the initial auth state
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});
  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const SplashPage());
  }

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkTutorialStatus();
    _redirect();
  }

  var _hasSeenTutorial = false;

  Future<void> _checkTutorialStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasSeenTutorial = prefs.getBool('hasSeenTutorial') ?? false;
    });
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    var loginRepo = ref.read(loginRepositoryProvider);
    final isLoggedIn = await loginRepo.isLoggedIn();
    if (!isLoggedIn) {
      Navigator.of(context).pushAndRemoveUntil(LoginPage.route(), (route) => false);
    } else {
      if (_hasSeenTutorial) {
        Navigator.of(context).pushAndRemoveUntil(MainPage.route(), (route) => false);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => Intro(
              child: const SwipePageTutorial(),
            ),
          ),
        );
      }
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: preloader);
  }
}
