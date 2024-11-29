import 'package:flutter/material.dart';
import 'package:movie_date/pages/room_page.dart';
import 'package:movie_date/pages/swipe_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const MainPage());
  }

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SwipePage(),
    const RoomPage(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        indicatorColor: Colors.amber,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
            selectedIcon: Icon(Icons.home),
          ),
          NavigationDestination(
            icon: Icon(Icons.room_outlined),
            label: 'Rooms',
            selectedIcon: Icon(Icons.room),
          ),
        ],
      ),
    );
  }
}
