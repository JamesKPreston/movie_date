import 'package:flutter/material.dart';
import 'package:movie_date/services/profile_service.dart';

class JoinPage extends StatelessWidget {
  JoinPage({super.key});
  final TextEditingController usernameController = TextEditingController();

  Future<void> joinRoom(String username) async {
    // Simulate a network call or database query
    var roomId = await ProfileService().getRoomIdByUsername(username);
    await ProfileService().updateProfileRoomId(roomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Get the value of the Username input and pass it to joinRoom
                final username = usernameController.text.trim();
                if (username.isNotEmpty) {
                  await joinRoom(username);
                } else {
                  // Optionally show a message if the field is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a username')),
                  );
                }
              },
              child: const Text('Join'),
            ),
          ],
        ),
      ),
    );
  }
}
