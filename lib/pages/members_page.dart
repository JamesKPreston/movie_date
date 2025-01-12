import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/pages/main_page.dart';
import 'package:movie_date/providers/members_repository_provider.dart';
import 'package:movie_date/providers/profile_repository_provider.dart';
import 'package:movie_date/providers/room_service_provider.dart';
import 'package:movie_date/widgets/menu_widget.dart';

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
  Map<String, Map<String, String>> _profiles = {}; // Stores member profile data
  bool _isLoading = true;
  String userId = '';

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    var membersRepo = ref.read(membersRepositoryProvider);
    var profileRepo = ref.read(profileRepositoryProvider);
    userId = await profileRepo.getCurrentUserId();
    final roomId = await membersRepo.getRoomIdByUserId(userId);
    final response = await membersRepo.getRoomMembers(roomId);

    // Fetch profile data for each member
    for (var member in response) {
      final profile = await profileRepo.getProfileByEmail(member);
      _profiles[member] = {
        'avatarUrl': profile.avatarUrl,
        'displayName': profile.displayName,
      };
    }

    setState(() {
      _members = response;
      _isLoading = false;
    });
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushAndRemoveUntil(MainPage.route(), (route) => false);
        break;
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
    roomService.createRoom(userId, "");
    Navigator.of(context).pushAndRemoveUntil(MainPage.route(), (route) => false);
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
          'Members',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      drawer: MenuWidget(),
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
                final profile = _profiles[member];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: profile?['avatarUrl'] != null && profile!['avatarUrl']!.isNotEmpty
                        ? NetworkImage(profile['avatarUrl']!)
                        : null,
                    child: profile?['avatarUrl'] == null || profile!['avatarUrl']!.isEmpty ? Icon(Icons.person) : null,
                  ),
                  title: Text(profile?['displayName'] ?? member),
                );
              },
            ),
    );
  }
}
