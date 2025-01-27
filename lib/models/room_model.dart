import 'package:movie_date/api/filters/movie.dart';

class Room {
  Room({
    required this.id,
    required this.filters,
    required this.room_code,
    required this.match_threshold,
  });

  /// Id of the room occupants record
  final String id;

  /// filters for the movie search
  final List<MovieFilters> filters;

  final String room_code;

  int match_threshold;

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] as String,
      filters: [MovieFilters.fromMap(map['filters'])],
      room_code: map['room_code'] as String,
      match_threshold: map['match_threshold'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filters': filters.map((filter) => filter.toMap()).toList().first,
      'room_code': room_code,
      'match_threshold': match_threshold,
    };
  }
}
