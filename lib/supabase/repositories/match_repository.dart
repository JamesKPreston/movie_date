import 'package:movie_date/repositories/match_repository.dart';
import 'package:movie_date/utils/constants.dart';
import 'package:movie_date/models/match_model.dart';

class SupabaseMatchRepository implements MatchRepository {
  SupabaseMatchRepository();

  @override
  Future<void> createMatch(Match match) async {
    await supabase.from('match').upsert(match.toJson());
  }

  @override
  Future<void> deleteMatch(Match match) async {
    try {
      await supabase.from('match').delete().eq('room_id', match.room_id).eq('movie_id', match.movie_id);
    } catch (e) {
      throw Exception('Failed to delete match: $e');
    }
  }

  @override
  Future<void> deleteMatchesByRoom(String room_id) async {
    try {
      await supabase.from('match').delete().eq('room_id', room_id);
    } catch (e) {
      throw Exception('Failed to delete matches by room: $e');
    }
  }

  @override
  Future<Match> getMatchByRoomAndMovie(String room_id, int movie_id) async {
    try {
      final response = await supabase.from('match').select().eq('room_id', room_id).eq('movie_id', movie_id).single();

      if (response == null) {
        throw Exception('Match not found');
      }

      return Match.fromMap(response);
    } catch (e) {
      throw Exception('Failed to get match: $e');
    }
  }

  @override
  Future<List<Match>> getMatchesByRoom(String room_id) async {
    try {
      final response = await supabase.from('match').select().eq('room_id', room_id);

      if (response == null || response.isEmpty) {
        return [];
      }

      return response.map<Match>((data) => Match.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get matches: $e');
    }
  }

  @override
  Future<void> updateMatch(Match match) async {
    try {
      // Attempt to fetch a single record
      final response = await supabase
          .from('match')
          .select()
          .eq('room_id', match.room_id)
          .eq('movie_id', match.movie_id)
          .maybeSingle();

      // If no record is found, set match_count to 1
      if (response == null) {
        match.match_count = 1;
      } else {
        // If a record is found, increment match_count
        match.match_count = response['match_count'] + 1;
      }

      // Upsert the match
      await supabase.from('match').upsert(match.toJson());
    } catch (e) {
      throw Exception('Failed to update match: $e');
    }
  }
}
