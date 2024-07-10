class MovieChoices {
  MovieChoices({required this.id, required this.profileId, required this.movieChoices});

  // Id of the movie choice record
  final String id;

  //User Id of the movie choice record
  final String profileId;

  // List of movie choices
  final List<String> movieChoices;

  // Converts a movie choice from a map to an object
  factory MovieChoices.fromMap(Map<String, dynamic> map) {
    return MovieChoices(
      id: map['id'] as String,
      profileId: map['profile_id'] as String,
      movieChoices: List<String>.from(map['movie_choices'] as List<dynamic>),
    );
  }
}
