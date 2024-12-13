import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jp_moviedb/filters/movie.dart';
import 'package:movie_date/providers/room_id_provider.dart';
import 'package:movie_date/services/room_service.dart';

final filtersProvider = FutureProvider<List<MovieFilters>>((ref) async {
  final roomId = await ref.watch(roomIdProvider.future);
  final room = await RoomService().getRoomByRoomId(roomId);

  return room.filters;
});
