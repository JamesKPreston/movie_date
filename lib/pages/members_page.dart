import 'package:flutter/material.dart';
import 'package:movie_date/repositories/members_repository.dart';
import 'package:movie_date/utils/constants.dart';

class MembersPage extends StatefulWidget {
  static Route<void> route({String mRoomId = ''}) {
    return MaterialPageRoute(
      builder: (context) => MembersPage(),
    );
  }

  const MembersPage({Key? key}) : super(key: key);

  @override
  _MembersPageState createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  List<String> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    final user = supabase.auth.currentUser;
    final roomId = await MembersRepository().getRoomIdByUserId(user!.id);
    final response = await MembersRepository().getRoomMembers(roomId);

    setState(() {
      _members = response;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Members'),
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
