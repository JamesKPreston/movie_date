import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jp_moviedb/filters/movie.dart';
import 'package:movie_date/providers/room_id_provider.dart';
import 'package:movie_date/repositories/movie_filters_repository.dart';
import 'package:movie_date/services/room_service.dart';

// Repository provider
final movieFiltersRepositoryProvider = Provider<MovieFiltersRepository>((ref) {
  return MovieFiltersRepository();
});

// StateNotifierProvider for fetching and holding the data
final movieFiltersProvider = FutureProvider<List<MovieFilters>>((ref) async {
  final repository = ref.watch(movieFiltersRepositoryProvider);
  return repository.fetchFilters();
});

final filtersProvider = FutureProvider<List<MovieFilters>>((ref) async {
  final roomId = await ref.watch(roomIdProvider.future);
  final room = await RoomService().getRoomByRoomId(roomId);

  return room.filters;
});
