import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/pages/members_page.dart';
import 'package:movie_date/pages/room_page.dart';
import 'package:movie_date/pages/swipe_page.dart';
import 'package:movie_date/providers/services/room_service_provider.dart';
import 'package:movie_date/providers/repositories/profile_repository_provider.dart';
import 'package:movie_date/widgets/menu_widget.dart';

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
    final profileRepository = ref.read(profileRepositoryProvider);

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
                  await roomService.joinRoom(roomCode, await profileRepository.getCurrentUserId());
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
      drawer: MenuWidget(),
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
