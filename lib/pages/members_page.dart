import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/pages/main_page.dart';
import 'package:movie_date/providers/members_repository_provider.dart';
import 'package:movie_date/providers/room_service_provider.dart';
import 'package:movie_date/utils/constants.dart';

class MembersPage extends ConsumerStatefulWidget {
  static Route<void> route({String mRoomId = ''}) {
    return MaterialPageRoute(
      builder: (context) => MembersPage(),
    );
  }

  const MembersPage({Key? key}) : super(key: key);

  @override
  _MembersPageState createState() => _MembersPageState();
}

class _MembersPageState extends ConsumerState<MembersPage> {
  int _selectedIndex = 0;
  List<String> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    var membersRepo = ref.read(membersRepositoryProvider);
    final user = supabase.auth.currentUser;
    final roomId = await membersRepo.getRoomIdByUserId(user!.id);
    final response = await membersRepo.getRoomMembers(roomId);

    setState(() {
      _members = response;
      _isLoading = false;
    });
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 1:
        _leaveRoom();
        break;
      default:
        setState(() {
          _selectedIndex = index;
        });
    }
  }

  Future<void> _leaveRoom() async {
    var roomService = ref.read(roomServiceProvider);
    final user = supabase.auth.currentUser;
    roomService.createRoom(user!.id, "");
    Navigator.of(context).pushAndRemoveUntil(MainPage.route(), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Members'),
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
            icon: Icon(Icons.logout_outlined),
            label: 'Leave Room',
            selectedIcon: Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final member = _members[index];
                return ListTile(
                  title: Text(member),
                );
              },
            ),
    );
  }
}
