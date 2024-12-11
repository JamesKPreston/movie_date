import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_date/pages/room_page.dart';
import 'package:movie_date/pages/swipe_page.dart';
import 'package:movie_date/services/profile_service.dart';

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
    Container(), // Placeholder for the Join Room modal
    const RoomPage(),
  ];

  void _onDestinationSelected(int index) {
    if (index == 1) {
      // Show the Join Room modal when Join Room is selected
      _showJoinRoomDialog();
    } else {
      setState(() {
        _selectedIndex = index;
      });
      _pageController.jumpToPage(index);
    }
  }

  void _showJoinRoomDialog() {
    TextEditingController roomCodeController = TextEditingController();

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
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Handle room code submission logic here
                final roomCode = roomCodeController.text;
                try {
                  var roomId = await ProfileService().getRoomIdByRoomCode(roomCode);
                  await ProfileService().updateProfileRoomId(roomId);
                } catch (e) {
                  // Show an error message if the room code is invalid
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid room code'),
                    ),
                  );
                  return;
                }

                Navigator.of(context).pushAndRemoveUntil(MainPage.route(), (route) => false); // Close the dialog
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
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // Prevent user-initiated horizontal scrolling in the PageView
          if (notification is OverscrollNotification || notification is ScrollUpdateNotification) {
            return true;
          }
          return false;
        },
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Prevent swipe gestures for PageView
          children: _pages,
        ),
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
