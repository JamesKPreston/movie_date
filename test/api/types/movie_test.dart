import 'package:flutter_test/flutter_test.dart';
import 'package:movie_date/api/types/movie.dart';
import 'package:movie_date/api/types/person.dart';
import 'package:movie_date/models/movie2_model.dart';

void main() {
  group('Movie Model Tests', () {
    test('fromJson creates Movie with all required fields', () {
      final json = {
        'title': 'Test Movie',
        'poster_path': '/poster.jpg',
        'overview': 'A test movie overview',
        'release_date': '2024-06-15',
        'original_language': 'en',
        'vote_average': 7.5,
        'backdrop_path': '/backdrop.jpg',
        'id': 12345,
        'original_title': 'Test Movie Original',
        'adult': false,
        'genre_ids': [28, 12, 878],
        'popularity': 100.5,
        'video': false,
        'vote_count': 1000,
      };

      final movie = Movie.fromJson(json);

      expect(movie.title, 'Test Movie');
      expect(movie.posterPath, 'https://image.tmdb.org/t/p/original/poster.jpg');
      expect(movie.overview, 'A test movie overview');
      expect(movie.releaseDate, DateTime.parse('2024-06-15'));
      expect(movie.language, 'en');
      expect(movie.voteAverage, 7.5);
      expect(movie.backdropPath, 'https://image.tmdb.org/t/p/original/backdrop.jpg');
      expect(movie.id, 12345);
      expect(movie.originalTitle, 'Test Movie Original');
      expect(movie.adult, false);
      expect(movie.genreIds, [28, 12, 878]);
      expect(movie.popularity, 100.5);
      expect(movie.video, false);
      expect(movie.voteCount, 1000);
    });

    test('fromJson handles runtime when present', () {
      final json = {
        'title': 'Test Movie',
        'poster_path': '/poster.jpg',
        'overview': 'Overview',
        'release_date': '2024-06-15',
        'original_language': 'en',
        'vote_average': 7.5,
        'backdrop_path': '/backdrop.jpg',
        'id': 12345,
        'original_title': 'Test Movie Original',
        'adult': false,
        'genre_ids': [28],
        'popularity': 100.5,
        'video': false,
        'vote_count': 1000,
        'runtime': 120,
      };

      final movie = Movie.fromJson(json);

      expect(movie.runtime, 120);
    });

    test('fromJson defaults runtime to 0 when not present', () {
      final json = {
        'title': 'Test Movie',
        'poster_path': '/poster.jpg',
        'overview': 'Overview',
        'release_date': '2024-06-15',
        'original_language': 'en',
        'vote_average': 7.5,
        'backdrop_path': '/backdrop.jpg',
        'id': 12345,
        'original_title': 'Test Movie Original',
        'adult': false,
        'genre_ids': [28],
        'popularity': 100.5,
        'video': false,
        'vote_count': 1000,
      };

      final movie = Movie.fromJson(json);

      expect(movie.runtime, 0);
    });

    test('Movie constructor with default values', () {
      final movie = Movie(
        title: 'Simple Movie',
        overview: 'Simple overview',
        releaseDate: DateTime(2024, 1, 1),
      );

      expect(movie.title, 'Simple Movie');
      expect(movie.posterPath, '');
      expect(movie.language, 'en');
      expect(movie.voteAverage, 0.0);
      expect(movie.backdropPath, '');
      expect(movie.id, 0);
      expect(movie.originalTitle, '');
      expect(movie.adult, false);
      expect(movie.genreIds, []);
      expect(movie.popularity, 0.0);
      expect(movie.video, false);
      expect(movie.voteCount, 0);
      expect(movie.runtime, 0);
    });

    test('Movie mutable fields can be modified', () {
      final movie = Movie(
        title: 'Original Title',
        overview: 'Original overview',
        releaseDate: DateTime(2024, 1, 1),
      );

      movie.title = 'Updated Title';
      movie.overview = 'Updated overview';
      movie.voteAverage = 8.5;
      movie.runtime = 150;

      expect(movie.title, 'Updated Title');
      expect(movie.overview, 'Updated overview');
      expect(movie.voteAverage, 8.5);
      expect(movie.runtime, 150);
    });

    test('fromJson handles empty genre_ids list', () {
      final json = {
        'title': 'Test Movie',
        'poster_path': '/poster.jpg',
        'overview': 'Overview',
        'release_date': '2024-06-15',
        'original_language': 'en',
        'vote_average': 7.5,
        'backdrop_path': '/backdrop.jpg',
        'id': 12345,
        'original_title': 'Test Movie Original',
        'adult': false,
        'genre_ids': [],
        'popularity': 100.5,
        'video': false,
        'vote_count': 1000,
      };

      final movie = Movie.fromJson(json);

      expect(movie.genreIds, []);
    });
  });

  group('Movie2 Model Tests', () {
    test('fromJson creates Movie2 with all fields', () {
      final json = {
        'title': 'Movie2 Test',
        'imageSet': {
          'verticalPoster': {
            'w720': 'https://example.com/poster.jpg',
          },
        },
        'overview': 'Movie2 overview',
        'releaseYear': 2024,
        'id': 'movie2-123',
        'originalTitle': 'Movie2 Original Title',
        'runtime': 135,
      };

      final movie2 = Movie2.fromJson(json);

      expect(movie2.title, 'Movie2 Test');
      expect(movie2.posterPath, 'https://example.com/poster.jpg');
      expect(movie2.overview, 'Movie2 overview');
      expect(movie2.releaseYear, 2024);
      expect(movie2.id, 'movie2-123');
      expect(movie2.originalTitle, 'Movie2 Original Title');
      expect(movie2.runtime, 135);
    });

    test('fromJson defaults runtime to 0 when not present', () {
      final json = {
        'title': 'Movie2 Test',
        'imageSet': {
          'verticalPoster': {
            'w720': 'https://example.com/poster.jpg',
          },
        },
        'overview': 'Movie2 overview',
        'releaseYear': 2024,
        'id': 'movie2-123',
        'originalTitle': 'Movie2 Original Title',
      };

      final movie2 = Movie2.fromJson(json);

      expect(movie2.runtime, 0);
    });

    test('Movie2 constructor with default values', () {
      final movie2 = Movie2(
        title: 'Simple Movie2',
        overview: 'Simple overview',
        releaseYear: 2024,
      );

      expect(movie2.title, 'Simple Movie2');
      expect(movie2.posterPath, '');
      expect(movie2.overview, 'Simple overview');
      expect(movie2.releaseYear, 2024);
      expect(movie2.id, '0');
      expect(movie2.originalTitle, '');
      expect(movie2.adult, false);
      expect(movie2.runtime, 0);
    });

    test('Movie2 mutable fields can be modified', () {
      final movie2 = Movie2(
        title: 'Original',
        overview: 'Original overview',
        releaseYear: 2020,
      );

      movie2.title = 'Updated';
      movie2.overview = 'Updated overview';
      movie2.releaseYear = 2024;
      movie2.runtime = 100;

      expect(movie2.title, 'Updated');
      expect(movie2.overview, 'Updated overview');
      expect(movie2.releaseYear, 2024);
      expect(movie2.runtime, 100);
    });
  });

  group('Person Model Tests', () {
    test('fromJson creates Person with all fields', () {
      final json = {
        'adult': false,
        'gender': 2,
        'id': 12345,
        'known_for_department': 'Acting',
        'name': 'John Doe',
        'original_name': 'John Doe Original',
        'popularity': 50.5,
        'profile_path': '/profile.jpg',
      };

      final person = Person.fromJson(json);

      expect(person.adult, false);
      expect(person.gender, 2);
      expect(person.id, 12345);
      expect(person.knownForDepartment, 'Acting');
      expect(person.name, 'John Doe');
      expect(person.originalName, 'John Doe Original');
      expect(person.popularity, 50.5);
      expect(person.profilePath, 'https://image.tmdb.org/t/p/original/profile.jpg');
    });

    test('fromJson handles null fields', () {
      final json = {
        'adult': null,
        'gender': null,
        'id': 12345,
        'known_for_department': null,
        'name': 'John Doe',
        'original_name': null,
        'popularity': null,
        'profile_path': null,
      };

      final person = Person.fromJson(json);

      expect(person.adult, null);
      expect(person.gender, null);
      expect(person.id, 12345);
      expect(person.knownForDepartment, null);
      expect(person.name, 'John Doe');
      expect(person.originalName, null);
      expect(person.popularity, null);
      expect(person.profilePath, 'https://image.tmdb.org/t/p/originalnull');
    });

    test('Person constructor with optional fields', () {
      final person = Person(
        id: 99999,
        name: 'Jane Doe',
      );

      expect(person.id, 99999);
      expect(person.name, 'Jane Doe');
      expect(person.adult, null);
      expect(person.gender, null);
      expect(person.knownForDepartment, null);
      expect(person.originalName, null);
      expect(person.popularity, null);
      expect(person.profilePath, null);
    });

    test('Person with known_for list', () {
      final person = Person(
        id: 12345,
        name: 'Actor Name',
        knownFor: [
          Movie(
            title: 'Famous Movie',
            overview: 'A famous movie',
            releaseDate: DateTime(2020),
          ),
        ],
      );

      expect(person.knownFor, isNotNull);
      expect(person.knownFor!.length, 1);
      expect(person.knownFor!.first.title, 'Famous Movie');
    });
  });
}
