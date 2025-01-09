import 'package:movie_date/models/profile_model.dart';
import 'package:movie_date/repositories/profile_repository.dart';
import 'package:movie_date/utils/constants.dart';

class SupabaseProfileRepository implements ProfileRepository {
  Future<String> getEmailById(String id) async {
    var result = await supabase.from('profiles').select('email').eq('id', id).single();
    return result['email'] as String;
  }

  Future<void> updateEmailById(String id, String email) async {
    await supabase.from('profiles').update({'email': email}).eq('id', id);
  }

  Future<String> getAvatarUrlById(String id) async {
    var result = await supabase.from('profiles').select('avatar_url').eq('id', id).single();
    return result['avatar_url'] as String;
  }

  Future<void> updateAvatarUrlById(String id, String avatarUrl) async {
    await supabase.from('profiles').update({'avatar_url': avatarUrl}).eq('id', id);
  }

  Future<String> getDisplayNameById(String id) async {
    var result = await supabase.from('profiles').select('display_name').eq('id', id).single();
    return result['display_name'] as String;
  }

  Future<void> updateDisplayNameById(String id, String displayName) async {
    await supabase.from('profiles').update({'display_name': displayName}).eq('id', id);
  }

  Future<Profile> getProfileByEmail(String email) async {
    var result = await supabase.from('profiles').select().eq('email', email).single();
    return Profile.fromMap(result);
  }

  Future<String> getCurrentUserId() async {
    return supabase.auth.currentUser!.id;
  }
}
