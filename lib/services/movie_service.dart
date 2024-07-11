import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jp_moviedb/api.dart';
import 'package:jp_moviedb/filters/movie.dart';
import 'package:jp_moviedb/types/movie.dart';
import 'package:movie_date/models/room.dart';
import 'package:movie_date/services/room_service.dart';
import 'package:movie_date/utils/constants.dart';

class MovieService {
  late TmdbApi api;
  List<Movie> movies = [];
  int count = 0;
  int page = 1;
  Future<List<Movie>> getMovies() async {
    // Fetch movies from the network
    await dotenv.load();
    api = TmdbApi(
      dotenv.env['API_KEY']!,
    );

    movies.clear();
    MovieFilters filters = MovieFilters();
    filters.page = page;
    filters.language = 'en';
    filters.primaryReleaseDateGte = DateTime(1986, 01, 01);
    filters.primaryReleaseDateLte = DateTime(1991, 01, 01);
    var result = await api.discover.getMovies(filters);
    return result;
  }

  Future<void> saveMovie(int movieId) async {
    Room room = await RoomService().getRoom();
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
  Future<List<int>> getMovieChoices() async {
    Room room = await RoomService().getRoom();

    var result2 = await supabase.rpc('getmoviechoices', params: {'room_id': room.id});
    List<int> movieIds = List<int>.from(jsonDecode(result2)).toList();
    return movieIds;
  }

  Future<List<int>> getUsersMovieChoices() async {
    Room room = await RoomService().getRoom();

    var result2 = await supabase.rpc('getusersmoviechoices', params: {'room_id': room.id});
    List<int> movieIds = List<int>.from(jsonDecode(result2)).toList();
    return movieIds;
  }

  Future<Movie> getMovie(int movieId) async {
    // Fetch movie from the network
    throw UnimplementedError();
  }
}
