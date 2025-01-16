import 'package:movie_date/models/match_model.dart';

abstract class MatchRepository {
  Future<Match> getMatchByRoomAndMovie(String room_id, int movie_id);
  Future<List<Match>> getMatchesByRoom(String room_id);
  Future<void> createMatch(Match match);
  Future<void> updateMatch(Match match);
  Future<void> deleteMatch(Match match);
  Future<void> deleteMatchesByRoom(String room_id);
}
