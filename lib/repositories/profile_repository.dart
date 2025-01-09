import 'dart:io';

import 'package:movie_date/models/profile_model.dart';

abstract class ProfileRepository {
  Future<String> getEmailById(String id);
  Future<void> updateEmailById(String id, String email);
  Future<String> getAvatarUrlById(String id);
  Future<void> updateAvatarUrlById(String id, String avatarUrl);
  Future<String> getDisplayNameById(String id);
  Future<void> updateDisplayNameById(String id, String displayName);
  Future<Profile> getProfileByEmail(String email);
  Future<String> getCurrentUserId();
  Future<String> uploadAvatar(File file);
}
