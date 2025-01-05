import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:movie_date/pages/login_page.dart';
import 'package:movie_date/pages/main_page.dart';
import 'package:movie_date/pages/members_page.dart';
import 'package:movie_date/pages/profile_page.dart';
import 'package:movie_date/pages/swipe_page_tutorial.dart';
import 'package:movie_date/utils/constants.dart';

class MenuWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            onTap: () {
              supabase.auth.signOut();
              Navigator.of(context).pushAndRemoveUntil(LoginPage.route(), (route) => false);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.black),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).push(MainPage.route());
            },
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.black),
            title: const Text('Profile'),
            onTap: () {
              Navigator.of(context).push(ProfilePage.route());
            },
          ),
          ListTile(
            leading: const Icon(Icons.movie, color: Colors.black),
            title: const Text('Room Members'),
            onTap: () {
              Navigator.of(context).push(MembersPage.route());
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
    );
  }
}
