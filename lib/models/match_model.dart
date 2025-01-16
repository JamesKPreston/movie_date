class Match {
  Match({
    required this.room_id,
    required this.movie_id,
    required this.match_count,
  });

  /// Id of the room occupants record
  final String room_id;

  /// filters for the movie search
  final int movie_id;

  int match_count;

  factory Match.fromMap(Map<String, dynamic> map) {
    return Match(
      room_id: map['room_id'] as String,
      movie_id: (map['movie_id'] as num).toInt(),
      match_count: (map['match_count'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': room_id,
      'movie_id': movie_id,
      'match_count': match_count,
    };
  }
}
