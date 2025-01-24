import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_date/controllers/auth_controller.dart';
import 'package:movie_date/pages/swipe_page_tutorial.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MenuWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authControllerNotifier = ref.read(authControllerProvider.notifier);

    return Drawer(
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final version = snapshot.hasData
              ? 'v${snapshot.data!.version} (${snapshot.data!.buildNumber})'
              : 'Loading version...';

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.black87,
                      ),
                      child: Text(
                        'Movie Date',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.black),
                      title: const Text('Log Out'),
                      onTap: () async {
                        try {
                          await authControllerNotifier.logout();
                          context.goNamed('home');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to log out: $e')),
                          );
                        }
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.home, color: Colors.black),
                      title: const Text('Home'),
                      onTap: () {
                        context.goNamed('main');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.people, color: Colors.black),
                      title: const Text('Profile'),
                      onTap: () {
                        context.goNamed('profile');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.movie, color: Colors.black),
                      title: const Text('Room Members'),
                      onTap: () {
                        context.goNamed('members');
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: Colors.black),
                      title: const Text('Tutorial'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => Intro(
                              child: const SwipePageTutorial(),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Column(
                  children: [
                    Text(
                      'Version',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      version,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
