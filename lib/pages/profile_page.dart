import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => ProfilePage());
  }
}

class _ProfilePageState extends State<ProfilePage> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  String? _avatarUrl;
  bool _isLoading = false;

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
      final fileName = 'avatars/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      final response = await _supabase.storage.from('avatars').upload(fileName, file);

      // if (response.error != null) {
      //   throw Exception('Failed to upload image: ${response.error!.message}');
      // }

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

      // final response = await _supabase.from('profiles').upsert({
      //   'id': user.id, // Assuming `id` is the primary key in the `profiles` table.
      //   'avatar_url': _avatarUrl,
      //   'display_name': _displayNameController.text,
      // }).execute();

      // if (response.error != null) {
      //   throw Exception('Failed to save profile: ${response.error!.message}');
      // }

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
      appBar: AppBar(title: Text('Profile')),
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
