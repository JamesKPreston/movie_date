import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/pages/login_page.dart';
import 'package:movie_date/pages/members_page.dart';
import 'package:movie_date/pages/room_page.dart';
import 'package:movie_date/pages/swipe_page.dart';
import 'package:movie_date/pages/swipe_page_tutorial.dart';
import 'package:movie_date/providers/room_service_provider.dart';
import 'package:movie_date/utils/constants.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const MainPage());
  }

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  List<Widget> _pages = [
    const SwipePage(),
    Container(), // Placeholder for the Join Room modal
    const RoomPage(),
    MembersPage(),
  ];

  void _onDestinationSelected(int index) {
    if (index == 1) {
      _showJoinRoomDialog();
    } else {
      setState(() {
        _selectedIndex = index;
      });
      _pageController.jumpToPage(index);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void _showJoinRoomDialog() {
    TextEditingController roomCodeController = TextEditingController();
    final roomService = ref.read(roomServiceProvider);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Join Room'),
          content: TextField(
            controller: roomCodeController,
            decoration: const InputDecoration(
              labelText: 'Enter Room Code',
              border: OutlineInputBorder(),
            ),
            inputFormatters: [
              UpperCaseTextFormatter(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final roomCode = roomCodeController.text;
                try {
                  await roomService.joinRoom(roomCode, supabase.auth.currentUser!.id);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid room code'),
                    ),
                  );
                  return;
                }

                Navigator.of(context).pushAndRemoveUntil(MainPage.route(), (route) => false);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 4.0,
        iconTheme: const IconThemeData(
          color: Colors.white, // Matches the AppBar text color
        ),
        title: const Text(
          'Movie Date',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
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
              leading: const Icon(Icons.movie, color: Colors.black),
              title: const Text('Room Members'),
              onTap: () {
                Navigator.pop(context);
                _pageController.jumpToPage(3);
              },
            ),
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
            const Divider(),
            ExpansionTile(
              leading: const Icon(Icons.meeting_room, color: Colors.black),
              title: const Text('Room'),
              children: [
                ListTile(
                  leading: const Icon(Icons.add, color: Colors.black),
                  title: const Text('Create Room'),
                  onTap: () {
                    Navigator.pop(context);
                    _pageController.jumpToPage(2);
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.input, color: Colors.black),
                  title: const Text('Join Room'),
                  onTap: _showJoinRoomDialog,
                ),
              ],
            ),
          ],
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is OverscrollNotification || notification is ScrollUpdateNotification) {
            return true;
          }
          return false;
        },
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        indicatorColor: Colors.white70,
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
            icon: Icon(Icons.filter_b_and_w_outlined),
            label: 'Filters',
            selectedIcon: Icon(Icons.filter_b_and_w),
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
