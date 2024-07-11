class MovieChoice {
  final int id;
  final String name;

  MovieChoice({required this.id, required this.name});

  // Converts a movie choice from JSON to an object
  factory MovieChoice.fromJson(Map<String, dynamic> json) {
    return MovieChoice(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
