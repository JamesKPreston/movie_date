import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/providers/members_repository_provider.dart';
import 'package:movie_date/providers/room_service_provider.dart';
import 'package:movie_date/utils/constants.dart';
import 'package:movie_date/widgets/menu_widget.dart';

class SettingsPage extends ConsumerStatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  double _matchThreshold = 2;
  double _maxThreshold = 10;
  bool _isMajority = false;

  Future<void> _saveSettings() async {
    final roomService = ref.read(roomServiceProvider);
    final room = await roomService.getRoomByUserId(supabase.auth.currentUser!.id);
    room.match_threshold = _matchThreshold.round();
    roomService.updateRoom(room);
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _setMaxThreshold();
  }

  Future<void> _setMaxThreshold() async {
    final roomService = ref.read(roomServiceProvider);
    final room = await roomService.getRoomByUserId(supabase.auth.currentUser!.id);
    final membersRepo = ref.read(membersRepositoryProvider);
    final membersCount = (await membersRepo.getRoomMembers(room.id)).length;
    setState(() {
      _maxThreshold = membersCount.toDouble();
    });
  }

  Future<void> _setMajorityThreshold() async {
    final roomService = ref.read(roomServiceProvider);
    final membersRepo = ref.read(membersRepositoryProvider);

    final room = await roomService.getRoomByUserId(supabase.auth.currentUser!.id);
    final membersCount = (await membersRepo.getRoomMembers(room.id)).length;

    setState(() {
      var threshold = (membersCount / 2).ceil().toDouble();
      _matchThreshold = threshold < 2 ? 2 : threshold;
    });
  }

  Future<void> _loadSettings() async {
    final roomService = ref.read(roomServiceProvider);
    final room = await roomService.getRoomByUserId(supabase.auth.currentUser!.id);
    setState(() {
      _matchThreshold = room.match_threshold.toDouble();
    });
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
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      drawer: MenuWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Matches Required',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _matchThreshold,
                    min: 2,
                    max: _maxThreshold,
                    divisions: 100,
                    label: _matchThreshold.round().toString(),
                    onChanged: _isMajority
                        ? null
                        : (double value) {
                            setState(() {
                              _matchThreshold = value;
                            });
                          },
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  '${_matchThreshold.round()}',
                  style: TextStyle(fontSize: 18.0),
                ),
              ],
            ),
            SizedBox(height: 20),
            CheckboxListTile(
              title: Text('Require Majority'),
              value: _isMajority,
              onChanged: (bool? value) {
                setState(() {
                  _isMajority = value ?? false;
                });
                if (_isMajority) {
                  _setMajorityThreshold();
                }
              },
            ),
            Center(
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: Text('Save Settings'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
