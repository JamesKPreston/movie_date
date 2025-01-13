abstract class MovieRepository {
  Future<void> saveMovie(int movieId, String profileId, String roomId);
  Map<int, int> getMovieCounts(List<int> movieIds);
  Future<Map<int, int>> getMovieChoices(String roomId);
  Future<Map<int, int>> getUsersMovieChoices(String roomId);
  Future<void> deleteMovieChoicesByRoomId(String roomId);
}
