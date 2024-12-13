import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jp_moviedb/filters/movie.dart';
import 'package:movie_date/providers/room_id_provider.dart';
import 'package:movie_date/providers/room_repository_provider.dart';

final filtersProvider = FutureProvider<List<MovieFilters>>((ref) async {
  final roomId = await ref.watch(roomIdProvider.future);
  var roomRepo = await ref.read(roomRepositoryProvider);
  final room = await roomRepo.getRoomByRoomId(roomId);

  return room.filters;
});
