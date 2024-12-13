import 'package:jp_moviedb/types/movie.dart';
import 'package:movie_date/repositories/movie_repository.dart';
import 'package:movie_date/repositories/profile_repository.dart';
import 'package:movie_date/repositories/room_repository.dart';
import 'package:movie_date/utils/constants.dart';

class MovieService {
  final MovieRepository movieRepository;
  final ProfileRepository profileRepository;
  final RoomRepository roomRepository;

  MovieService(this.movieRepository, this.profileRepository, this.roomRepository);

  Future<List<Movie>> getMovies(int page) async {
    final user = supabase.auth.currentUser;
    final roomCode = await profileRepository.getRoomCodeById(user!.id);
    final roomId = await profileRepository.getRoomIdByRoomCode(roomCode);
    final room = await roomRepository.getRoomByRoomId(roomId);

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

  Future<void> saveMovie(int movieId) async {
    final user = supabase.auth.currentUser;
    final roomCode = await profileRepository.getRoomCodeById(user!.id);
    final roomId = await profileRepository.getRoomIdByRoomCode(roomCode);
    final room = await roomRepository.getRoomByRoomId(roomId);

    await movieRepository.saveMovie(movieId, user.id, room.id);
  }

  Future<bool> isMovieSaved(int movieId) async {
    final user = supabase.auth.currentUser;
    final roomCode = await profileRepository.getRoomCodeById(user!.id);
    final roomId = await profileRepository.getRoomIdByRoomCode(roomCode);

    final otherUsersChoices = await movieRepository.getMovieChoices(roomId);
    final myChoices = await movieRepository.getUsersMovieChoices(roomId);

    return otherUsersChoices.contains(movieId) && myChoices.contains(movieId);
  }
}
