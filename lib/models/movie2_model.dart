class Movie2 {
  String title;
  String overview;
  int releaseYear;
  final String id;
  final String originalTitle;
  String posterPath;
  final bool adult;
  //final List<String> genres;

  int runtime;

  Movie2(
      {required this.title,
      this.posterPath = '',
      required this.overview,
      required this.releaseYear,
      this.id = '0',
      this.originalTitle = '',
      this.adult = false,
      // this.genres = const [],
      this.runtime = 0});

  factory Movie2.fromJson(Map<String, dynamic> json) {
    return Movie2(
      title: json['title'],
      posterPath: json['imageSet']['verticalPoster']['w720'],
      overview: json['overview'],
      releaseYear: json['releaseYear'],
      id: json['id'],
      originalTitle: json['originalTitle'],
      // genres: List<String>.from(json['genres']),
      runtime: json.containsKey('runtime') ? json['runtime'] : 0,
    );
  }
}
