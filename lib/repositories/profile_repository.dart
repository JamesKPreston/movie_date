import 'package:movie_date/utils/constants.dart';

class ProfileRepository {
  Future<String> getEmailById(String id) async {
    var result = await supabase.from('profiles').select('email').eq('id', id).single();
    return result['email'] as String;
  }
}
