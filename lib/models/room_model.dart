import 'package:jp_moviedb/filters/movie.dart';

class Room {
  Room({
    required this.id,
    required this.filters,
    required this.room_code,
  });

  /// Id of the room occupants record
  final String id;

  /// filters for the movie search
  final List<MovieFilters> filters;

  final String room_code;

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] as String,
      filters: [MovieFilters.fromMap(map['filters'])],
      room_code: map['room_code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filters': filters.map((filter) => filter.toMap()).toList().first,
      'room_code': room_code,
    };
  }
}
