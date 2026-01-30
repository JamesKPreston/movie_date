import 'package:flutter_test/flutter_test.dart';
import 'package:movie_date/models/profile_model.dart';
import 'package:movie_date/models/room_model.dart';
import 'package:movie_date/models/match_model.dart';
import 'package:movie_date/models/member_model.dart';
import 'package:movie_date/api/filters/movie.dart';

void main() {
  group('Profile Model Tests', () {
    test('fromMap creates Profile with all fields', () {
      final map = {
        'id': 'user-123',
        'created_at': '2024-01-15T10:30:00.000Z',
        'email': 'test@example.com',
        'avatar_url': 'https://example.com/avatar.png',
        'display_name': 'Test User',
      };

      final profile = Profile.fromMap(map);

      expect(profile.id, 'user-123');
      expect(profile.email, 'test@example.com');
      expect(profile.avatarUrl, 'https://example.com/avatar.png');
      expect(profile.displayName, 'Test User');
      expect(profile.createdAt, DateTime.parse('2024-01-15T10:30:00.000Z'));
    });

    test('fromMap handles null avatar_url with default empty string', () {
      final map = {
        'id': 'user-123',
        'created_at': '2024-01-15T10:30:00.000Z',
        'email': 'test@example.com',
        'avatar_url': null,
        'display_name': 'Test User',
      };

      final profile = Profile.fromMap(map);

      expect(profile.avatarUrl, '');
    });

    test('fromMap uses email as display_name when display_name is null', () {
      final map = {
        'id': 'user-123',
        'created_at': '2024-01-15T10:30:00.000Z',
        'email': 'test@example.com',
        'avatar_url': 'https://example.com/avatar.png',
        'display_name': null,
      };

      final profile = Profile.fromMap(map);

      expect(profile.displayName, 'test@example.com');
    });

    test('Profile constructor creates instance with required fields', () {
      final profile = Profile(
        id: 'user-456',
        createdAt: DateTime(2024, 1, 15),
        email: 'user@test.com',
        avatarUrl: '',
        displayName: 'User Name',
      );

      expect(profile.id, 'user-456');
      expect(profile.email, 'user@test.com');
      expect(profile.displayName, 'User Name');
    });
  });

  group('Room Model Tests', () {
    test('fromMap creates Room with all fields', () {
      final map = {
        'id': 'room-123',
        'room_code': 'ABC123',
        'match_threshold': 2,
        'filters': {
          'page': 1,
          'language': 'en',
        },
      };

      final room = Room.fromMap(map);

      expect(room.id, 'room-123');
      expect(room.room_code, 'ABC123');
      expect(room.match_threshold, 2);
      expect(room.filters.length, 1);
      expect(room.filters.first.page, 1);
      expect(room.filters.first.language, 'en');
    });

    test('toJson serializes Room correctly', () {
      final filter = MovieFilters(page: 1, language: 'en');
      final room = Room(
        id: 'room-456',
        filters: [filter],
        room_code: 'XYZ789',
        match_threshold: 3,
      );

      final json = room.toJson();

      expect(json['id'], 'room-456');
      expect(json['room_code'], 'XYZ789');
      expect(json['match_threshold'], 3);
      expect(json['filters']['page'], 1);
      expect(json['filters']['language'], 'en');
    });

    test('Room roundtrip serialization works correctly', () {
      final filter = MovieFilters(page: 2, language: 'es');
      final original = Room(
        id: 'room-789',
        filters: [filter],
        room_code: 'TEST01',
        match_threshold: 4,
      );

      final json = original.toJson();
      // Manually reconstruct to simulate round-trip
      final reconstructed = Room(
        id: json['id'] as String,
        filters: [MovieFilters.fromMap(json['filters'] as Map<String, dynamic>)],
        room_code: json['room_code'] as String,
        match_threshold: json['match_threshold'] as int,
      );

      expect(reconstructed.id, original.id);
      expect(reconstructed.room_code, original.room_code);
      expect(reconstructed.match_threshold, original.match_threshold);
      expect(reconstructed.filters.first.page, original.filters.first.page);
    });

    test('Room match_threshold is mutable', () {
      final room = Room(
        id: 'room-123',
        filters: [MovieFilters()],
        room_code: 'ABC123',
        match_threshold: 2,
      );

      expect(room.match_threshold, 2);
      room.match_threshold = 5;
      expect(room.match_threshold, 5);
    });
  });

  group('Match Model Tests', () {
    test('fromMap creates Match with all fields', () {
      final map = {
        'room_id': 'room-123',
        'movie_id': 12345,
        'match_count': 2,
      };

      final match = Match.fromMap(map);

      expect(match.room_id, 'room-123');
      expect(match.movie_id, 12345);
      expect(match.match_count, 2);
    });

    test('fromMap handles numeric types correctly', () {
      // Test with double values (as might come from JSON)
      final map = {
        'room_id': 'room-123',
        'movie_id': 12345.0,
        'match_count': 3.0,
      };

      final match = Match.fromMap(map);

      expect(match.movie_id, 12345);
      expect(match.match_count, 3);
    });

    test('toJson serializes Match correctly', () {
      final match = Match(
        room_id: 'room-456',
        movie_id: 67890,
        match_count: 4,
      );

      final json = match.toJson();

      expect(json['room_id'], 'room-456');
      expect(json['movie_id'], 67890);
      expect(json['match_count'], 4);
    });

    test('Match roundtrip serialization works correctly', () {
      final original = Match(
        room_id: 'room-789',
        movie_id: 11111,
        match_count: 1,
      );

      final json = original.toJson();
      final reconstructed = Match.fromMap(json);

      expect(reconstructed.room_id, original.room_id);
      expect(reconstructed.movie_id, original.movie_id);
      expect(reconstructed.match_count, original.match_count);
    });

    test('Match match_count is mutable', () {
      final match = Match(
        room_id: 'room-123',
        movie_id: 12345,
        match_count: 0,
      );

      expect(match.match_count, 0);
      match.match_count = 5;
      expect(match.match_count, 5);
    });
  });

  group('Member Model Tests', () {
    test('fromMap creates Member with all fields', () {
      final map = {
        'id': 'member-123',
        'room_id': 'room-456',
        'user_id': 'user-789',
        'email': 'member@example.com',
      };

      final member = Member.fromMap(map);

      expect(member.id, 'member-123');
      expect(member.room_id, 'room-456');
      expect(member.user_id, 'user-789');
      expect(member.email, 'member@example.com');
    });

    test('toJson serializes Member with email correctly', () {
      final member = Member(
        id: 'member-123',
        room_id: 'room-456',
        user_id: 'user-789',
        email: 'member@example.com',
      );

      final json = member.toJson();

      expect(json['id'], 'member-123');
      expect(json['room_id'], 'room-456');
      expect(json['user_id'], 'user-789');
      expect(json['email'], 'member@example.com');
    });

    test('toJson excludes email when empty', () {
      final member = Member(
        id: 'member-123',
        room_id: 'room-456',
        user_id: 'user-789',
        email: '',
      );

      final json = member.toJson();

      expect(json['id'], 'member-123');
      expect(json['room_id'], 'room-456');
      expect(json['user_id'], 'user-789');
      expect(json.containsKey('email'), false);
    });

    test('Member roundtrip serialization with email works correctly', () {
      final original = Member(
        id: 'member-abc',
        room_id: 'room-def',
        user_id: 'user-ghi',
        email: 'test@test.com',
      );

      final json = original.toJson();
      final reconstructed = Member.fromMap(json);

      expect(reconstructed.id, original.id);
      expect(reconstructed.room_id, original.room_id);
      expect(reconstructed.user_id, original.user_id);
      expect(reconstructed.email, original.email);
    });
  });
}
