import 'dart:io';

import 'package:movie_date/models/profile_model.dart';
import 'package:movie_date/repositories/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  Future<String> getEmailById(String id) async {
    throw UnimplementedError();
  }

  Future<void> updateEmailById(String id, String email) async {
    throw UnimplementedError();
  }

  Future<String> getAvatarUrlById(String id) async {
    throw UnimplementedError();
  }

  Future<void> updateAvatarUrlById(String id, String avatarUrl) async {
    throw UnimplementedError();
  }

  Future<String> getDisplayNameById(String id) async {
    throw UnimplementedError();
  }

  Future<void> updateDisplayNameById(String id, String displayName) async {
    throw UnimplementedError();
  }

  Future<Profile> getProfileByEmail(String email) async {
    throw UnimplementedError();
  }

  Future<String> getCurrentUserId() async {
    throw UnimplementedError();
  }

  Future<String> uploadAvatar(File file) async {
    throw UnimplementedError();
  }
}
