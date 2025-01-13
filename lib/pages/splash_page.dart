import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_date/utils/constants.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    context.goNamed('main');
    return const Scaffold(body: preloader);
  }
}
