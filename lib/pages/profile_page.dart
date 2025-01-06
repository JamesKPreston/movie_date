import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movie_date/providers/profile_repository_provider.dart';
import 'package:movie_date/widgets/menu_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends ConsumerStatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => ProfilePage());
  }
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  String? _avatarUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = _supabase.auth.currentUser;
    if (user != null) {
      var profileRepo = ref.read(profileRepositoryProvider);
      profileRepo.getDisplayNameById(user.id).then((value) => _displayNameController.text = value);
      profileRepo.getAvatarUrlById(user.id).then((value) => setState(() => _avatarUrl = value));
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final file = File(pickedFile.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      await _supabase.storage.from('avatars').upload(fileName, file);

      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);

      setState(() {
        _avatarUrl = imageUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      var profileRepo = ref.read(profileRepositoryProvider);
      await profileRepo.updateDisplayNameById(user.id, _displayNameController.text);
      await profileRepo.updateAvatarUrlById(user.id, _avatarUrl!);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile saved!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          'Profile',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _isLoading ? null : _pickAndUploadImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                  child: _avatarUrl == null ? Icon(Icons.add_a_photo, size: 50) : null,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a display name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading ? CircularProgressIndicator() : Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
