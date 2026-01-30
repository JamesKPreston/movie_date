import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_date/api/filters/movie.dart';
import 'package:movie_date/models/member_model.dart';
import 'package:movie_date/models/profile_model.dart';
import 'package:movie_date/models/room_model.dart';
import 'package:movie_date/repositories/members_repository.dart';
import 'package:movie_date/repositories/profile_repository.dart';
import 'package:movie_date/repositories/room_repository.dart';
import 'package:movie_date/services/room_service.dart';

// Mock implementations
class MockRoomRepository implements RoomRepository {
  Room? room;
  bool addRoomCalled = false;
  Room? addedRoom;
  bool updateRoomCalled = false;
  Room? updatedRoom;
  bool shouldThrowOnGetRoomId = false;

  MockRoomRepository() {
    room = Room(
      id: 'test-room-id',
      filters: [MovieFilters(page: 1, language: 'en')],
      room_code: 'ABC123',
      match_threshold: 2,
    );
  }

  @override
  Future<Room> getRoomByRoomId(String id) async {
    if (room != null && room!.id == id) {
      return room!;
    }
    return Room(
      id: id,
      filters: [MovieFilters(page: 1, language: 'en')],
      room_code: 'ABC123',
      match_threshold: 2,
    );
  }

  @override
  Future<void> addRoom(Room newRoom) async {
    addRoomCalled = true;
    addedRoom = newRoom;
    room = newRoom;
  }

  @override
  Future<String> getRoomCodeById(String id) async => room?.room_code ?? 'ABC123';

  @override
  Future<String> getRoomIdByRoomCode(String roomCode) async {
    if (shouldThrowOnGetRoomId) {
      throw Exception('Room not found');
    }
    return 'test-room-id';
  }

  @override
  Future<void> deleteRoom(Room room) async {}

  @override
  Future<void> updateRoom(Room newRoom) async {
    updateRoomCalled = true;
    updatedRoom = newRoom;
    room = newRoom;
  }
}

class MockMembersRepository implements MembersRepository {
  String roomId = 'test-room-id';
  List<String> members = ['test@example.com', 'other@example.com'];
  bool addMemberCalled = false;
  Member? addedMember;
  bool shouldThrowOnGetRoomId = false;

  @override
  Future<List<String>> getRoomMembers(String roomId) async {
    return members;
  }

  @override
  Future<void> addMember(Member member) async {
    addMemberCalled = true;
    addedMember = member;
  }

  @override
  Future<String> getRoomIdByUserId(String userId) async {
    if (shouldThrowOnGetRoomId) {
      throw Exception('User not in a room');
    }
    return roomId;
  }
}

class MockProfileRepository implements ProfileRepository {
  String currentUserId = 'test-user-id';
  String email = 'test@example.com';

  @override
  Future<String> getCurrentUserId() async => currentUserId;

  @override
  Future<String> getEmailById(String id) async => email;

  @override
  Future<void> updateEmailById(String id, String email) async {}

  @override
  Future<String> getAvatarUrlById(String id) async => '';

  @override
  Future<void> updateAvatarUrlById(String id, String avatarUrl) async {}

  @override
  Future<String> getDisplayNameById(String id) async => 'Test User';

  @override
  Future<void> updateDisplayNameById(String id, String displayName) async {}

  @override
  Future<Profile> getProfileByEmail(String email) async {
    return Profile.fromMap({
      'id': currentUserId,
      'created_at': DateTime.now().toIso8601String(),
      'email': email,
      'avatar_url': '',
      'display_name': 'Test User',
    });
  }

  @override
  Future<String> uploadAvatar(File file) async => '';
}

void main() {
  late MockRoomRepository mockRoomRepository;
  late MockMembersRepository mockMembersRepository;
  late MockProfileRepository mockProfileRepository;
  late RoomService roomService;

  setUp(() {
    mockRoomRepository = MockRoomRepository();
    mockMembersRepository = MockMembersRepository();
    mockProfileRepository = MockProfileRepository();
    roomService = RoomService(
      mockRoomRepository,
      mockMembersRepository,
      mockProfileRepository,
    );
  });

  group('RoomService.createRoom Tests', () {
    test('createRoom creates room with correct initial values', () async {
      await roomService.createRoom('new-user-id', 'newuser@example.com');

      expect(mockRoomRepository.addRoomCalled, true);
      expect(mockRoomRepository.addedRoom, isNotNull);
      expect(mockRoomRepository.addedRoom!.match_threshold, 2);
      expect(mockRoomRepository.addedRoom!.filters.length, 1);
      expect(mockRoomRepository.addedRoom!.filters.first.page, 1);
      expect(mockRoomRepository.addedRoom!.filters.first.language, 'en');
    });

    test('createRoom generates 6-character uppercase room code', () async {
      await roomService.createRoom('new-user-id', 'newuser@example.com');

      expect(mockRoomRepository.addedRoom!.room_code.length, 6);
      expect(mockRoomRepository.addedRoom!.room_code, mockRoomRepository.addedRoom!.room_code.toUpperCase());
    });

    test('createRoom adds member with correct data', () async {
      await roomService.createRoom('new-user-id', 'newuser@example.com');

      expect(mockMembersRepository.addMemberCalled, true);
      expect(mockMembersRepository.addedMember!.id, 'new-user-id');
      expect(mockMembersRepository.addedMember!.user_id, 'new-user-id');
      expect(mockMembersRepository.addedMember!.email, 'newuser@example.com');
      expect(mockMembersRepository.addedMember!.room_id, mockRoomRepository.addedRoom!.id);
    });

    test('createRoom generates unique room ID', () async {
      await roomService.createRoom('user-1', 'user1@example.com');
      final firstRoomId = mockRoomRepository.addedRoom!.id;

      mockRoomRepository = MockRoomRepository();
      mockMembersRepository = MockMembersRepository();
      roomService = RoomService(
        mockRoomRepository,
        mockMembersRepository,
        mockProfileRepository,
      );

      await roomService.createRoom('user-2', 'user2@example.com');
      final secondRoomId = mockRoomRepository.addedRoom!.id;

      // UUIDs should be different (extremely unlikely to be the same)
      expect(firstRoomId, isNot(secondRoomId));
    });
  });

  group('RoomService.updateFiltersForRoom Tests', () {
    test('updateFiltersForRoom updates room with new filters', () async {
      final newFilters = [
        MovieFilters(
          page: 2,
          language: 'es',
          withGenres: '28,12',
        ),
      ];

      await roomService.updateFiltersForRoom(newFilters);

      expect(mockRoomRepository.addRoomCalled, true);
      expect(mockRoomRepository.addedRoom!.filters.first.language, 'es');
      expect(mockRoomRepository.addedRoom!.filters.first.withGenres, '28,12');
    });

    test('updateFiltersForRoom preserves room ID and room code', () async {
      final originalRoom = mockRoomRepository.room!;
      final newFilters = [MovieFilters(page: 3, language: 'fr')];

      await roomService.updateFiltersForRoom(newFilters);

      expect(mockRoomRepository.addedRoom!.id, originalRoom.id);
      expect(mockRoomRepository.addedRoom!.room_code, originalRoom.room_code);
      expect(mockRoomRepository.addedRoom!.match_threshold, originalRoom.match_threshold);
    });

    test('updateFiltersForRoom gets current user room', () async {
      final newFilters = [MovieFilters(page: 1)];

      await roomService.updateFiltersForRoom(newFilters);

      // Service should have fetched the current user's room
      expect(mockRoomRepository.addRoomCalled, true);
    });
  });

  group('RoomService.getRoomCodeById Tests', () {
    test('getRoomCodeById returns room code', () async {
      final result = await roomService.getRoomCodeById('test-user-id');

      expect(result, 'ABC123');
    });

    test('getRoomCodeById throws exception on error', () async {
      mockMembersRepository.shouldThrowOnGetRoomId = true;

      expect(
        () => roomService.getRoomCodeById('test-user-id'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to get room code'),
        )),
      );
    });
  });

  group('RoomService.getRoomByUserId Tests', () {
    test('getRoomByUserId returns room', () async {
      final result = await roomService.getRoomByUserId('test-user-id');

      expect(result, isNotNull);
      expect(result.id, 'test-room-id');
      expect(result.room_code, 'ABC123');
    });

    test('getRoomByUserId returns room with correct filters', () async {
      final result = await roomService.getRoomByUserId('test-user-id');

      expect(result.filters.length, 1);
      expect(result.filters.first.page, 1);
      expect(result.filters.first.language, 'en');
    });
  });

  group('RoomService.joinRoom Tests', () {
    test('joinRoom adds member to existing room', () async {
      await roomService.joinRoom('ABC123', 'new-user-id');

      expect(mockMembersRepository.addMemberCalled, true);
      expect(mockMembersRepository.addedMember!.user_id, 'new-user-id');
      expect(mockMembersRepository.addedMember!.room_id, 'test-room-id');
    });

    test('joinRoom retrieves email for new member', () async {
      mockProfileRepository.email = 'joined@example.com';

      await roomService.joinRoom('ABC123', 'joining-user-id');

      expect(mockMembersRepository.addedMember!.email, 'joined@example.com');
    });

    test('joinRoom throws exception when room not found', () async {
      mockRoomRepository.shouldThrowOnGetRoomId = true;

      expect(
        () => roomService.joinRoom('INVALID', 'user-id'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to join room'),
        )),
      );
    });
  });

  group('RoomService.updateRoom Tests', () {
    test('updateRoom calls repository with room', () async {
      final updatedRoom = Room(
        id: 'test-room-id',
        filters: [MovieFilters(page: 1)],
        room_code: 'XYZ789',
        match_threshold: 3,
      );

      await roomService.updateRoom(updatedRoom);

      expect(mockRoomRepository.updateRoomCalled, true);
      expect(mockRoomRepository.updatedRoom!.room_code, 'XYZ789');
      expect(mockRoomRepository.updatedRoom!.match_threshold, 3);
    });
  });

  group('RoomService.getFiltersByRoomId Tests', () {
    test('getFiltersByRoomId returns filters for room', () async {
      final result = await roomService.getFiltersByRoomId('test-room-id');

      expect(result, isNotNull);
      expect(result.length, 1);
      expect(result.first.page, 1);
      expect(result.first.language, 'en');
    });

    test('getFiltersByRoomId returns filters with all properties', () async {
      mockRoomRepository.room = Room(
        id: 'test-room-id',
        filters: [
          MovieFilters(
            page: 2,
            language: 'de',
            withGenres: '35,18',
            primaryReleaseDateGte: DateTime(2020),
            primaryReleaseDateLte: DateTime(2024),
          ),
        ],
        room_code: 'ABC123',
        match_threshold: 2,
      );

      final result = await roomService.getFiltersByRoomId('test-room-id');

      expect(result.first.page, 2);
      expect(result.first.language, 'de');
      expect(result.first.withGenres, '35,18');
      expect(result.first.primaryReleaseDateGte, DateTime(2020));
      expect(result.first.primaryReleaseDateLte, DateTime(2024));
    });
  });
}
