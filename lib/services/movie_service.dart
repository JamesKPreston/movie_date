import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jp_moviedb/api.dart';
import 'package:jp_moviedb/types/movie.dart';
import 'package:movie_date/services/profile_service.dart';
import 'package:movie_date/services/room_service.dart';
import 'package:movie_date/utils/constants.dart';

class MovieService {
  late TmdbApi api;
  List<Movie> movies = [];
  int count = 0;
  Future<List<Movie>> getMovies(int page) async {
    // Fetch movies from the network
    await dotenv.load();
    api = TmdbApi(
      dotenv.env['API_KEY']!,
    );
    final user = supabase.auth.currentUser;
    final room_code = await ProfileService().getRoomCodeById(user!.id);
    try {
      final roomId = await ProfileService().getRoomIdByRoomCode(room_code);
      final room = await RoomService().getRoomByRoomId(roomId);
      room.filters.first.page = page;

      movies.clear();
      if (room.filters.first.withGenres == "") {
        room.filters.first.withGenres = null;
      }
      if (room.filters.first.withCast == "") {
        room.filters.first.withCast = null;
      }

      var result = await api.discover.getMovies(room.filters.first);

      result = await Future.wait(result.map((movie) async {
        var detailedMovie = await api.discover.getMovieDetails(movie);
        return detailedMovie;
      }));
      return result;
    } catch (e) {
      return [];
    }
  }

  Future<void> saveMovie(int movieId) async {
    final user = supabase.auth.currentUser;
    final room_code = await ProfileService().getRoomCodeById(user!.id);
    final roomId = await ProfileService().getRoomIdByRoomCode(room_code);
    final room = await RoomService().getRoomByRoomId(roomId);

    // Save movie to the database
    await supabase
        .from('moviechoices')
        .upsert({
          'profile_id': supabase.auth.currentUser!.id,
          'movie_id': movieId,
          'room_id': room.id,
        })
        .eq('profile_id', supabase.auth.currentUser!.id)
        .eq('movie_id', movieId)
        .eq('room_id', room.id);
  }

  //Get Movie Choices
  Future<List<int>> _getMovieChoices() async {
    final user = supabase.auth.currentUser;
    final room_code = await ProfileService().getRoomCodeById(user!.id);
    final roomId = await ProfileService().getRoomIdByRoomCode(room_code);
    final room = await RoomService().getRoomByRoomId(roomId);

    var result = await supabase.rpc('getmoviechoices', params: {'room_id': room.id});
    List<int> movieIds = List<int>.from(jsonDecode(result)).toList();
    return movieIds;
  }

  Future<List<int>> _getUsersMovieChoices() async {
    final user = supabase.auth.currentUser;
    final room_code = await ProfileService().getRoomCodeById(user!.id);
    final roomId = await ProfileService().getRoomIdByRoomCode(room_code);
    final room = await RoomService().getRoomByRoomId(roomId);

    var result = await supabase.rpc('getusersmoviechoices', params: {'room_id': room.id});
    if (result == null) {
      return [];
    }
    List<int> movieIds = List<int>.from(jsonDecode(result)).toList();
    return movieIds;
  }

  Future<Movie> getMovie(int movieId) async {
    // Fetch movie from the network
    await dotenv.load();
    api = TmdbApi(
      dotenv.env['API_KEY']!,
    );
    Movie movie = Movie(title: '', overview: '', releaseDate: DateTime.now(), id: movieId);
    return await api.discover.getMovieDetails(movie);
  }

  Future<bool> isMovieSaved(int movieId) async {
    // Check if movie is saved in the database
    List<int> otherUsersChoices = await MovieService()._getMovieChoices();
    List<int> myChoices = await MovieService()._getUsersMovieChoices();

    return (otherUsersChoices.contains(movieId) && myChoices.contains(movieId));
  }
}
