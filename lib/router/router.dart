import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_date/api/types/person.dart';
import 'package:movie_date/pages/actor_page.dart';
import 'package:movie_date/pages/login_page.dart';
import 'package:movie_date/pages/main_page.dart';
import 'package:movie_date/pages/match_found_page.dart';
import 'package:movie_date/pages/members_page.dart';
import 'package:movie_date/pages/profile_page.dart';
import 'package:movie_date/pages/settings_page.dart';
import 'package:movie_date/pages/splash_page.dart';
import 'package:movie_date/pages/room_page.dart';
import 'package:movie_date/pages/swipe_page_tutorial.dart';
import 'package:movie_date/providers/login_repository_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

GoRouter createRouter(WidgetRef ref) {
  return GoRouter(
    redirect: (BuildContext context, GoRouterState state) async {
      var loginRepo = ref.read(loginRepositoryProvider);
      final isAuthenticated = await loginRepo.isLoggedIn();
      if (!isAuthenticated) {
        return '/login';
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      //prefs.setBool('hasSeenTutorial', false);
      final _hasSeenTutorial = prefs.getBool('hasSeenTutorial') ?? false;
      if (!_hasSeenTutorial && state.uri.toString() != '/tutorial') {
        return '/tutorial';
      }

      return null;
    },
    initialLocation: '/',
    routes: [
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => SplashPage(),
      ),
      GoRoute(
        name: 'filters',
        path: '/filters',
        builder: (context, state) => RoomPage(),
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        name: 'main',
        path: '/main',
        builder: (context, state) => MainPage(),
      ),
      GoRoute(
        name: 'profile',
        path: '/profile',
        builder: (context, state) => ProfilePage(),
      ),
      GoRoute(
        name: 'members',
        path: '/members',
        builder: (context, state) => MembersPage(),
      ),
      GoRoute(
        name: 'tutorial',
        path: '/tutorial',
        builder: (context, state) {
          return Intro(
            child: const SwipePageTutorial(),
          );
        },
      ),
      GoRoute(
        name: 'actors',
        path: '/actors',
        builder: (context, state) {
          final selectedActors = state.extra as List<Person>?; // Retrieve the extra data
          return ActorPage(
            currentlySelectedActors: selectedActors ?? [],
          );
        },
      ),
      GoRoute(
        name: 'match_found',
        path: '/match_found',
        builder: (context, state) {
          final movieId = state.extra as int; // Retrieve the extra data (movie ID)
          return MatchFoundPage(movieId: movieId); // Pass the movie ID to the MatchFoundPage
        },
      ),
      GoRoute(
        name: 'settings',
        path: '/settings',
        builder: (context, state) => SettingsPage(),
      ),
      // GoRoute(
      //   name: 'temp',
      //   path: '/temp',
      //   builder: (context, state) => MyHomePage(),
      // ),
    ],
  );
}
