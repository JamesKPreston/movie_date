import 'package:flutter/material.dart';
import 'package:movie_date/pages/join_page.dart';
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
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const SwipePage(),
    JoinPage(),
    const RoomPage(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
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
            icon: Icon(Icons.door_front_door_outlined),
            label: 'Join Room',
            selectedIcon: Icon(Icons.door_front_door),
          ),
          NavigationDestination(
            icon: Icon(Icons.domain_add_outlined),
            label: 'Create Room',
            selectedIcon: Icon(Icons.domain_add),
          ),
        ],
      ),
    );
  }
}
