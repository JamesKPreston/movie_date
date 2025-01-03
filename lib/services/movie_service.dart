import 'package:jp_moviedb/types/movie.dart';
import 'package:movie_date/repositories/members_repository.dart';
import 'package:movie_date/repositories/movie_repository.dart';
import 'package:movie_date/repositories/profile_repository.dart';
import 'package:movie_date/repositories/room_repository.dart';
import 'package:movie_date/utils/constants.dart';

class MovieService {
  final MovieRepository movieRepository;
  final ProfileRepository profileRepository;
  final RoomRepository roomRepository;
  final MembersRepository memberRepository;

  MovieService(this.movieRepository, this.profileRepository, this.roomRepository, this.memberRepository);

  Future<List<Movie>> getMovies(int page) async {
    final user = supabase.auth.currentUser;
    final room = await memberRepository.getRoomIdByUserId(user!.id).then((roomId) {
      return roomRepository.getRoomByRoomId(roomId);
    });

    room.filters.first.page = page;

    if (room.filters.first.withGenres == "") {
      room.filters.first.withGenres = null;
    }
    if (room.filters.first.withCast == "") {
      room.filters.first.withCast = null;
    }

    var result = await movieRepository.getMoviesWithFilters(room.filters.first);

    result = await Future.wait(result.map((movie) async {
      return await movieRepository.getMovieDetails(movie);
    }));

    return result;
  }

  Future<List<int>> getSavedMoviesByRoomId() async {
    final user = supabase.auth.currentUser;
    final room = await memberRepository.getRoomIdByUserId(user!.id).then((roomId) {
      return roomRepository.getRoomByRoomId(roomId);
    });
    final movieIds = await movieRepository.getMovieChoices(room.id);
    return movieIds.keys.toList();
  }

  Future<void> saveMovie(int movieId) async {
    final user = supabase.auth.currentUser;
    final roomId = await memberRepository.getRoomIdByUserId(user!.id);

    await movieRepository.saveMovie(movieId, user.id, roomId);
  }

  Future<bool> isMovieSaved(int movieId) async {
    final user = supabase.auth.currentUser;
    final roomId = await memberRepository.getRoomIdByUserId(user!.id);

    final otherUsersChoices = await movieRepository.getMovieChoices(roomId);
    final myChoices = await movieRepository.getUsersMovieChoices(roomId);

    return otherUsersChoices.containsKey(movieId) && myChoices.containsKey(movieId);
  }

  Future<int> findMatchingMovieId() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception("User is not logged in");
    }

    final roomId = await memberRepository.getRoomIdByUserId(user.id);

    final otherUsersChoices = await movieRepository.getMovieChoices(roomId);
    final myChoices = await movieRepository.getUsersMovieChoices(roomId);

    for (final key in otherUsersChoices.keys) {
      if (myChoices.containsKey(key)) {
        return key; // Return the matching movie ID
      }
    }

    return 0; // Return 0 if no matching key is found
  }

  Future<void> deleteMovieChoicesByRoomId() async {
    final user = supabase.auth.currentUser;
    final roomId = await memberRepository.getRoomIdByUserId(user!.id);

    await movieRepository.deleteMovieChoicesByRoomId(roomId);
  }
}
