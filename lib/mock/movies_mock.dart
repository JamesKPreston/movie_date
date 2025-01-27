import 'package:movie_date/api/types/movie.dart';

class MoviesMock {
  static List<Movie> getMovies() {
    return [
      Movie(
        posterPath: "https://image.tmdb.org/t/p/original/eOoCzH0MqeGr2taUZO4SwG416PF.jpg",
        title: 'The Polar Express',
        runtime: 100,
        genreIds: [16, 12, 10751, 14],
        voteAverage: 6.723,
        overview:
            'When a doubting young boy takes an extraordinary train ride to the North Pole, he embarks on a journey of self-discovery that shows him that the wonder of life never fades for those who believe.',
        releaseDate: DateTime(2004, 11, 10),
      ),
      Movie(
          title: 'Toy Story',
          runtime: 81,
          genreIds: [16, 12, 10751, 14],
          voteAverage: 6.723,
          overview:
              "Led by Woody, Andy's toys live happily in his room until Andy's birthday brings Buzz Lightyear onto the scene. Afraid of losing his place in Andy's heart, Woody plots against Buzz. But when circumstances separate Buzz and Woody from their owner, the duo eventually learns to put aside their differences.",
          releaseDate: DateTime(1995, 10, 30),
          posterPath: "https://image.tmdb.org/t/p/original/uXDfjJbdP4ijW5hWSBrPrlKpxab.jpg"),
      Movie(
        posterPath: "https://image.tmdb.org/t/p/original/79euHUJJtfgeGU63ef38KtNjXEn.jpg",
        title: 'Here',
        runtime: 105,
        genreIds: [16, 12, 10751, 14],
        voteAverage: 6.472,
        overview:
            'An odyssey through time and memory, centered around a place in New England where—from wilderness, and then, later, from a home—love, loss, struggle, hope and legacy play out between couples and families over generations.',
        releaseDate: DateTime(2024, 10, 30),
      ),
      Movie(
        posterPath: "https://image.tmdb.org/t/p/original/AbbXspMOwdvwWZgVN0nabZq03Ec.jpg",
        title: 'Toy Story 3',
        runtime: 103,
        genreIds: [16, 12, 10751, 14],
        voteAverage: 7.8,
        overview:
            "Woody, Buzz, and the rest of Andy's toys haven't been played with in years. With Andy about to go to college, the gang find themselves accidentally left at a nefarious day care center. The toys must band together to escape and return home to Andy.",
        releaseDate: DateTime(2010, 06, 16),
      ),
    ];
  }
}
