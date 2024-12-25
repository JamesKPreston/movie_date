import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jp_moviedb/filters/movie.dart';
import 'package:movie_date/providers/room_service_provider.dart';
import 'package:movie_date/utils/constants.dart';

final filtersProvider = FutureProvider<List<MovieFilters>>((ref) async {
  var roomService = await ref.read(roomServiceProvider);
  var room = await roomService.getRoomByUserId(supabase.auth.currentUser!.id);

  return room.filters;
});
