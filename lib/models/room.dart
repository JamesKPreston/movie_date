import 'package:jp_moviedb/filters/movie.dart';

class Room {
  Room({
    required this.id,
    required this.filters,
  });

  /// Id of the room occupants record
  final String id;

  /// filters for the movie search
  final List<MovieFilters> filters;

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] as String,
      filters: [MovieFilters.fromMap(map['filters'])],
    );
  }
}
