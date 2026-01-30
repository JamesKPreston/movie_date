import 'package:flutter_test/flutter_test.dart';
import 'package:movie_date/api/types/movie.dart';
import 'package:movie_date/models/movie2_model.dart';
import 'package:movie_date/utils/conversion.dart';

void main() {
  group('ConversionUtils Tests', () {
    test('toMovie converts Movie2 to Movie with all fields', () {
      final movie2 = Movie2(
        title: 'Test Movie',
        posterPath: 'https://example.com/poster.jpg',
        overview: 'A test movie overview',
        releaseYear: 2024,
        id: '12345',
        originalTitle: 'Original Test Movie',
        runtime: 120,
      );

      final movie = ConversionUtils.toMovie(movie2);

      expect(movie.title, 'Test Movie');
      expect(movie.posterPath, 'https://example.com/poster.jpg');
      expect(movie.overview, 'A test movie overview');
      expect(movie.releaseDate, DateTime(2024));
      expect(movie.id, 12345);
      expect(movie.originalTitle, 'Original Test Movie');
      expect(movie.runtime, 120);
    });

    test('toMovie converts Movie2 with minimal fields', () {
      final movie2 = Movie2(
        title: 'Minimal Movie',
        overview: 'Minimal overview',
        releaseYear: 2020,
      );

      final movie = ConversionUtils.toMovie(movie2);

      expect(movie.title, 'Minimal Movie');
      expect(movie.overview, 'Minimal overview');
      expect(movie.releaseDate, DateTime(2020));
      expect(movie.id, 0);
      expect(movie.originalTitle, '');
      expect(movie.runtime, 0);
    });

    test('toMovie correctly converts releaseYear to DateTime', () {
      final movie2 = Movie2(
        title: 'Year Test',
        overview: 'Testing year conversion',
        releaseYear: 1999,
      );

      final movie = ConversionUtils.toMovie(movie2);

      expect(movie.releaseDate.year, 1999);
      expect(movie.releaseDate.month, 1);
      expect(movie.releaseDate.day, 1);
    });

    test('toMovie correctly parses string ID to integer', () {
      final movie2 = Movie2(
        title: 'ID Test',
        overview: 'Testing ID conversion',
        releaseYear: 2024,
        id: '99999',
      );

      final movie = ConversionUtils.toMovie(movie2);

      expect(movie.id, 99999);
    });

    test('toMovie preserves poster path as is', () {
      final movie2 = Movie2(
        title: 'Poster Test',
        overview: 'Testing poster',
        releaseYear: 2024,
        posterPath: 'https://cdn.example.com/images/poster.jpg',
      );

      final movie = ConversionUtils.toMovie(movie2);

      expect(movie.posterPath, 'https://cdn.example.com/images/poster.jpg');
    });

    test('toMovie handles empty poster path', () {
      final movie2 = Movie2(
        title: 'No Poster',
        overview: 'No poster available',
        releaseYear: 2024,
        posterPath: '',
      );

      final movie = ConversionUtils.toMovie(movie2);

      expect(movie.posterPath, '');
    });

    test('toMovie handles zero runtime', () {
      final movie2 = Movie2(
        title: 'Zero Runtime',
        overview: 'Unknown runtime',
        releaseYear: 2024,
        runtime: 0,
      );

      final movie = ConversionUtils.toMovie(movie2);

      expect(movie.runtime, 0);
    });

    test('toMovie handles large runtime values', () {
      final movie2 = Movie2(
        title: 'Long Movie',
        overview: 'Very long movie',
        releaseYear: 2024,
        runtime: 300, // 5 hours
      );

      final movie = ConversionUtils.toMovie(movie2);

      expect(movie.runtime, 300);
    });

    test('toMovie handles historical release years', () {
      final movie2 = Movie2(
        title: 'Classic Movie',
        overview: 'An old classic',
        releaseYear: 1920,
      );

      final movie = ConversionUtils.toMovie(movie2);

      expect(movie.releaseDate.year, 1920);
    });

    test('toMovie result has correct default values for non-mapped fields', () {
      final movie2 = Movie2(
        title: 'Default Values Test',
        overview: 'Testing defaults',
        releaseYear: 2024,
      );

      final movie = ConversionUtils.toMovie(movie2);

      // Fields that are not mapped from Movie2 should have defaults
      expect(movie.language, 'en');
      expect(movie.voteAverage, 0.0);
      expect(movie.backdropPath, '');
      expect(movie.adult, false);
      expect(movie.genreIds, []);
      expect(movie.popularity, 0.0);
      expect(movie.video, false);
      expect(movie.voteCount, 0);
    });

    test('toMovie handles special characters in title and overview', () {
      final movie2 = Movie2(
        title: 'Test & Movie: The "Sequel" (2024)',
        overview: 'An overview with special chars: <>&"\'',
        releaseYear: 2024,
      );

      final movie = ConversionUtils.toMovie(movie2);

      expect(movie.title, 'Test & Movie: The "Sequel" (2024)');
      expect(movie.overview, 'An overview with special chars: <>&"\'');
    });

    test('toMovie handles unicode characters', () {
      final movie2 = Movie2(
        title: '映画テスト',
        overview: 'Descripción de la película 电影描述',
        releaseYear: 2024,
      );

      final movie = ConversionUtils.toMovie(movie2);

      expect(movie.title, '映画テスト');
      expect(movie.overview, 'Descripción de la película 电影描述');
    });
  });
}
