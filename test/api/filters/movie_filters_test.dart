import 'package:flutter_test/flutter_test.dart';
import 'package:movie_date/api/filters/movie.dart';
import 'package:movie_date/api/types/person.dart';

void main() {
  group('MovieFilters Model Tests', () {
    test('default constructor creates MovieFilters with default values', () {
      final filters = MovieFilters();

      expect(filters.page, null);
      expect(filters.language, null);
      expect(filters.primaryReleaseDateGte, null);
      expect(filters.primaryReleaseDateLte, null);
      expect(filters.withGenres, null);
      expect(filters.withCast, null);
      expect(filters.persons, null);
      expect(filters.watchRegion, null);
      expect(filters.withWatchProviders, null);
    });

    test('constructor with parameters sets values correctly', () {
      final startDate = DateTime(2020, 1, 1);
      final endDate = DateTime(2024, 12, 31);

      final filters = MovieFilters(
        page: 1,
        language: 'en',
        primaryReleaseDateGte: startDate,
        primaryReleaseDateLte: endDate,
        withGenres: '28,12',
        withCast: '12345',
        watchRegion: 'US',
        withWatchProviders: '8|9',
      );

      expect(filters.page, 1);
      expect(filters.language, 'en');
      expect(filters.primaryReleaseDateGte, startDate);
      expect(filters.primaryReleaseDateLte, endDate);
      expect(filters.withGenres, '28,12');
      expect(filters.withCast, '12345');
      expect(filters.watchRegion, 'US');
      expect(filters.withWatchProviders, '8|9');
    });

    test('fromMap creates MovieFilters with basic fields', () {
      final map = {
        'page': 2,
        'language': 'es',
      };

      final filters = MovieFilters.fromMap(map);

      expect(filters.page, 2);
      expect(filters.language, 'es');
    });

    test('fromMap creates MovieFilters with date fields', () {
      final map = {
        'page': 1,
        'language': 'en',
        'primaryReleaseDateGte': '2020-01-01T00:00:00.000',
        'primaryReleaseDateLte': '2024-12-31T00:00:00.000',
      };

      final filters = MovieFilters.fromMap(map);

      expect(filters.primaryReleaseDateGte, DateTime(2020, 1, 1));
      expect(filters.primaryReleaseDateLte, DateTime(2024, 12, 31));
    });

    test('fromMap handles null date fields', () {
      final map = {
        'page': 1,
        'language': 'en',
        'primaryReleaseDateGte': null,
        'primaryReleaseDateLte': null,
      };

      final filters = MovieFilters.fromMap(map);

      expect(filters.primaryReleaseDateGte, null);
      expect(filters.primaryReleaseDateLte, null);
    });

    test('fromMap creates MovieFilters with genre and cast fields', () {
      final map = {
        'page': 1,
        'language': 'en',
        'withGenres': '28,12,878',
        'withCast': '12345,67890',
      };

      final filters = MovieFilters.fromMap(map);

      expect(filters.withGenres, '28,12,878');
      expect(filters.withCast, '12345,67890');
    });

    test('fromMap creates MovieFilters with watch provider fields', () {
      final map = {
        'page': 1,
        'language': 'en',
        'watchRegion': 'US',
        'withWatchProviders': '8|9|337',
      };

      final filters = MovieFilters.fromMap(map);

      expect(filters.watchRegion, 'US');
      expect(filters.withWatchProviders, '8|9|337');
    });

    test('fromMap creates MovieFilters with persons list', () {
      final map = {
        'page': 1,
        'language': 'en',
        'persons': [
          {
            'adult': false,
            'gender': 2,
            'id': 12345,
            'known_for_department': 'Acting',
            'name': 'John Doe',
            'original_name': 'John Doe',
            'popularity': 50.0,
            'profile_path': '/profile.jpg',
          },
          {
            'adult': false,
            'gender': 1,
            'id': 67890,
            'known_for_department': 'Acting',
            'name': 'Jane Doe',
            'original_name': 'Jane Doe',
            'popularity': 45.0,
            'profile_path': '/profile2.jpg',
          },
        ],
      };

      final filters = MovieFilters.fromMap(map);

      expect(filters.persons, isNotNull);
      expect(filters.persons!.length, 2);
      expect(filters.persons![0].id, 12345);
      expect(filters.persons![0].name, 'John Doe');
      expect(filters.persons![1].id, 67890);
      expect(filters.persons![1].name, 'Jane Doe');
    });

    test('toMap serializes basic fields correctly', () {
      final filters = MovieFilters(
        page: 3,
        language: 'fr',
      );

      final map = filters.toMap();

      expect(map['page'], 3);
      expect(map['language'], 'fr');
    });

    test('toMap serializes date fields as ISO8601 strings', () {
      final startDate = DateTime(2020, 6, 15);
      final endDate = DateTime(2024, 12, 25);

      final filters = MovieFilters(
        page: 1,
        language: 'en',
        primaryReleaseDateGte: startDate,
        primaryReleaseDateLte: endDate,
      );

      final map = filters.toMap();

      expect(map['primaryReleaseDateGte'], startDate.toIso8601String());
      expect(map['primaryReleaseDateLte'], endDate.toIso8601String());
    });

    test('toMap omits null optional fields', () {
      final filters = MovieFilters(
        page: 1,
        language: 'en',
      );

      final map = filters.toMap();

      expect(map.containsKey('primaryReleaseDateGte'), false);
      expect(map.containsKey('primaryReleaseDateLte'), false);
      expect(map.containsKey('withGenres'), false);
      expect(map.containsKey('withCast'), false);
      expect(map.containsKey('withWatchProviders'), false);
      expect(map.containsKey('watchRegion'), false);
      expect(map.containsKey('persons'), false);
    });

    test('toMap serializes genre and cast fields', () {
      final filters = MovieFilters(
        page: 1,
        language: 'en',
        withGenres: '28,12',
        withCast: '12345',
      );

      final map = filters.toMap();

      expect(map['withGenres'], '28,12');
      expect(map['withCast'], '12345');
    });

    test('toMap serializes watch provider fields', () {
      final filters = MovieFilters(
        page: 1,
        language: 'en',
        watchRegion: 'GB',
        withWatchProviders: '8|9',
      );

      final map = filters.toMap();

      expect(map['watchRegion'], 'GB');
      expect(map['withWatchProviders'], '8|9');
    });

    test('toMap serializes persons list correctly', () {
      final filters = MovieFilters(
        page: 1,
        language: 'en',
        persons: [
          Person(
            adult: false,
            gender: 2,
            id: 12345,
            knownForDepartment: 'Acting',
            name: 'John Doe',
            originalName: 'John Doe Original',
            popularity: 50.0,
            profilePath: 'https://example.com/profile.jpg',
          ),
        ],
      );

      final map = filters.toMap();

      expect(map['persons'], isNotNull);
      expect(map['persons'], isA<List>());
      expect((map['persons'] as List).length, 1);

      final personMap = (map['persons'] as List).first as Map<String, dynamic>;
      expect(personMap['adult'], false);
      expect(personMap['gender'], 2);
      expect(personMap['id'], 12345);
      expect(personMap['known_for_department'], 'Acting');
      expect(personMap['name'], 'John Doe');
      expect(personMap['original_name'], 'John Doe Original');
      expect(personMap['popularity'], 50.0);
      expect(personMap['profile_path'], 'https://example.com/profile.jpg');
    });

    test('MovieFilters roundtrip serialization works correctly', () {
      final original = MovieFilters(
        page: 5,
        language: 'de',
        primaryReleaseDateGte: DateTime(2019, 1, 1),
        primaryReleaseDateLte: DateTime(2023, 12, 31),
        withGenres: '35,18',
        withCast: '99999',
        watchRegion: 'DE',
        withWatchProviders: '337',
      );

      final map = original.toMap();
      final reconstructed = MovieFilters.fromMap(map);

      expect(reconstructed.page, original.page);
      expect(reconstructed.language, original.language);
      expect(reconstructed.primaryReleaseDateGte, original.primaryReleaseDateGte);
      expect(reconstructed.primaryReleaseDateLte, original.primaryReleaseDateLte);
      expect(reconstructed.withGenres, original.withGenres);
      expect(reconstructed.withCast, original.withCast);
      expect(reconstructed.watchRegion, original.watchRegion);
      expect(reconstructed.withWatchProviders, original.withWatchProviders);
    });

    test('MovieFilters with persons roundtrip serialization', () {
      final original = MovieFilters(
        page: 1,
        language: 'en',
        persons: [
          Person(
            id: 12345,
            name: 'Actor Name',
            adult: false,
            gender: 2,
            knownForDepartment: 'Acting',
            originalName: 'Actor Original Name',
            popularity: 75.5,
            profilePath: 'https://example.com/actor.jpg',
          ),
        ],
      );

      final map = original.toMap();
      final reconstructed = MovieFilters.fromMap(map);

      expect(reconstructed.persons, isNotNull);
      expect(reconstructed.persons!.length, 1);
      expect(reconstructed.persons![0].id, original.persons![0].id);
      expect(reconstructed.persons![0].name, original.persons![0].name);
    });

    test('MovieFilters default property values', () {
      final filters = MovieFilters();

      // Check default values defined in the class
      expect(filters.includeAdult, false);
      expect(filters.includeVideo, false);
      expect(filters.sortBy, 'popularity.desc');
    });

    test('MovieFilters additional properties can be set', () {
      final filters = MovieFilters();

      filters.certification = 'PG-13';
      filters.certificationCountry = 'US';
      filters.year = 2024;
      filters.withRuntimeGte = 90;
      filters.withRuntimeLte = 180;

      expect(filters.certification, 'PG-13');
      expect(filters.certificationCountry, 'US');
      expect(filters.year, 2024);
      expect(filters.withRuntimeGte, 90);
      expect(filters.withRuntimeLte, 180);
    });
  });
}
