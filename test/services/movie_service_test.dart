import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_date/api/filters/movie.dart';
import 'package:movie_date/api/types/movie.dart';
import 'package:movie_date/models/match_model.dart';
import 'package:movie_date/models/member_model.dart';
import 'package:movie_date/models/profile_model.dart';
import 'package:movie_date/models/room_model.dart';
import 'package:movie_date/models/watch_options.dart';
import 'package:movie_date/repositories/match_repository.dart';
import 'package:movie_date/repositories/members_repository.dart';
import 'package:movie_date/repositories/movie_repository.dart';
import 'package:movie_date/repositories/profile_repository.dart';
import 'package:movie_date/repositories/room_repository.dart';
import 'package:movie_date/services/movie_service.dart';

// Mock implementations
class MockMovieRepository implements MovieRepository {
  List<Movie> moviesWithFilters = [];
  Map<int, int> movieChoices = {};
  Map<int, int> usersMovieChoices = {};
  List<Movie> topMovies = [];
  bool saveMovieCalled = false;
  int? savedMovieId;
  String? savedProfileId;
  String? savedRoomId;
  bool deleteMovieChoicesCalled = false;

  @override
  Future<List<Movie>> getMoviesWithFilters(dynamic filter) async {
    return moviesWithFilters;
  }

  @override
  Future<Movie> getMovieDetails(Movie movie) async {
    return movie;
  }

  @override
  Future<Movie> getMovie(int movieId) async {
    return Movie(
      id: movieId,
      title: 'Test Movie $movieId',
      overview: 'Test overview',
      releaseDate: DateTime(2024),
    );
  }

  @override
  Future<void> saveMovie(int movieId, String profileId, String roomId) async {
    saveMovieCalled = true;
    savedMovieId = movieId;
    savedProfileId = profileId;
    savedRoomId = roomId;
  }

  @override
  Map<int, int> getMovieCounts(List<int> movieIds) {
    return {};
  }

  @override
  Future<Map<int, int>> getMovieChoices(String roomId) async {
    return movieChoices;
  }

  @override
  Future<Map<int, int>> getUsersMovieChoices(String roomId) async {
    return usersMovieChoices;
  }

  @override
  Future<void> deleteMovieChoicesByRoomId(String roomId) async {
    deleteMovieChoicesCalled = true;
  }

  @override
  Future<List<WatchOption>> getMovieWatchOptions(int movieId) async {
    return [];
  }

  @override
  Future<List<Movie>> getTopMoviesByStreamingService(String service) async {
    return topMovies;
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

class MockRoomRepository implements RoomRepository {
  Room? room;
  bool addRoomCalled = false;
  Room? addedRoom;

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
    return room!;
  }

  @override
  Future<void> addRoom(Room newRoom) async {
    addRoomCalled = true;
    addedRoom = newRoom;
    room = newRoom;
  }

  @override
  Future<String> getRoomCodeById(String id) async => 'ABC123';

  @override
  Future<String> getRoomIdByRoomCode(String roomCode) async => 'test-room-id';

  @override
  Future<void> deleteRoom(Room room) async {}

  @override
  Future<void> updateRoom(Room room) async {}
}

class MockMembersRepository implements MembersRepository {
  String roomId = 'test-room-id';
  List<String> members = ['test@example.com', 'other@example.com'];
  bool addMemberCalled = false;
  Member? addedMember;

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
  Future<String> getRoomIdByUserId(String userId) async => roomId;
}

class MockMatchRepository implements MatchRepository {
  bool updateMatchCalled = false;
  Match? updatedMatch;
  bool deleteMatchesCalled = false;

  @override
  Future<List<Match>> getMatchesByRoom(String roomId) async => [];

  @override
  Future<void> createMatch(Match match) async {}

  @override
  Future<void> deleteMatch(Match match) async {}

  @override
  Future<void> deleteMatchesByRoom(String roomId) async {
    deleteMatchesCalled = true;
  }

  @override
  Future<Match> getMatchByRoomAndMovie(String roomId, int movieId) async {
    return Match(room_id: roomId, movie_id: movieId, match_count: 0);
  }

  @override
  Future<void> updateMatch(Match match) async {
    updateMatchCalled = true;
    updatedMatch = match;
  }
}

void main() {
  late MockMovieRepository mockMovieRepository;
  late MockProfileRepository mockProfileRepository;
  late MockRoomRepository mockRoomRepository;
  late MockMembersRepository mockMembersRepository;
  late MockMatchRepository mockMatchRepository;
  late MovieService movieService;

  setUp(() {
    mockMovieRepository = MockMovieRepository();
    mockProfileRepository = MockProfileRepository();
    mockRoomRepository = MockRoomRepository();
    mockMembersRepository = MockMembersRepository();
    mockMatchRepository = MockMatchRepository();
    movieService = MovieService(
      mockMovieRepository,
      mockProfileRepository,
      mockRoomRepository,
      mockMembersRepository,
      mockMatchRepository,
    );
  });

  group('MovieService.getMovies Tests', () {
    test('getMovies returns list of movies with details', () async {
      final testMovies = [
        Movie(
          id: 1,
          title: 'Movie 1',
          overview: 'Overview 1',
          releaseDate: DateTime(2024),
        ),
        Movie(
          id: 2,
          title: 'Movie 2',
          overview: 'Overview 2',
          releaseDate: DateTime(2024),
        ),
      ];
      mockMovieRepository.moviesWithFilters = testMovies;

      final result = await movieService.getMovies(1);

      expect(result.length, 2);
      expect(result[0].title, 'Movie 1');
      expect(result[1].title, 'Movie 2');
    });

    test('getMovies returns empty list when no movies match filters', () async {
      mockMovieRepository.moviesWithFilters = [];

      final result = await movieService.getMovies(1);

      expect(result, isEmpty);
    });

    test('getMovies sets page number from parameter', () async {
      mockMovieRepository.moviesWithFilters = [];

      await movieService.getMovies(5);

      // The service should set the page number on the filter
      expect(mockRoomRepository.room!.filters.first.page, 5);
    });

    test('getMovies clears empty withGenres string to null', () async {
      mockRoomRepository.room!.filters.first.withGenres = '';
      mockMovieRepository.moviesWithFilters = [];

      await movieService.getMovies(1);

      expect(mockRoomRepository.room!.filters.first.withGenres, null);
    });

    test('getMovies clears empty withCast string to null', () async {
      mockRoomRepository.room!.filters.first.withCast = '';
      mockMovieRepository.moviesWithFilters = [];

      await movieService.getMovies(1);

      expect(mockRoomRepository.room!.filters.first.withCast, null);
    });
  });

  group('MovieService.getSavedMoviesByRoomId Tests', () {
    test('getSavedMoviesByRoomId returns list of movie IDs', () async {
      mockMovieRepository.movieChoices = {
        123: 1,
        456: 2,
        789: 1,
      };

      final result = await movieService.getSavedMoviesByRoomId();

      expect(result.length, 3);
      expect(result.contains(123), true);
      expect(result.contains(456), true);
      expect(result.contains(789), true);
    });

    test('getSavedMoviesByRoomId returns empty list when no movies saved', () async {
      mockMovieRepository.movieChoices = {};

      final result = await movieService.getSavedMoviesByRoomId();

      expect(result, isEmpty);
    });
  });

  group('MovieService.saveMovie Tests', () {
    test('saveMovie calls repository with correct parameters', () async {
      await movieService.saveMovie(12345);

      expect(mockMovieRepository.saveMovieCalled, true);
      expect(mockMovieRepository.savedMovieId, 12345);
      expect(mockMovieRepository.savedProfileId, 'test-user-id');
      expect(mockMovieRepository.savedRoomId, 'test-room-id');
    });

    test('saveMovie updates match repository', () async {
      await movieService.saveMovie(12345);

      expect(mockMatchRepository.updateMatchCalled, true);
      expect(mockMatchRepository.updatedMatch!.room_id, 'test-room-id');
      expect(mockMatchRepository.updatedMatch!.movie_id, 12345);
      expect(mockMatchRepository.updatedMatch!.match_count, 0);
    });
  });

  group('MovieService.isMovieSaved Tests', () {
    test('isMovieSaved returns true when movie is in both user and others choices', () async {
      mockMovieRepository.movieChoices = {12345: 1};
      mockMovieRepository.usersMovieChoices = {12345: 1};

      final result = await movieService.isMovieSaved(12345);

      expect(result, true);
    });

    test('isMovieSaved returns false when movie is only in others choices', () async {
      mockMovieRepository.movieChoices = {12345: 1};
      mockMovieRepository.usersMovieChoices = {};

      final result = await movieService.isMovieSaved(12345);

      expect(result, false);
    });

    test('isMovieSaved returns false when movie is only in user choices', () async {
      mockMovieRepository.movieChoices = {};
      mockMovieRepository.usersMovieChoices = {12345: 1};

      final result = await movieService.isMovieSaved(12345);

      expect(result, false);
    });

    test('isMovieSaved returns false when movie is in neither', () async {
      mockMovieRepository.movieChoices = {};
      mockMovieRepository.usersMovieChoices = {};

      final result = await movieService.isMovieSaved(99999);

      expect(result, false);
    });
  });

  group('MovieService.findMatchingMovieId Tests', () {
    test('findMatchingMovieId returns matching movie ID', () async {
      mockMovieRepository.movieChoices = {123: 1, 456: 1};
      mockMovieRepository.usersMovieChoices = {456: 1, 789: 1};

      final result = await movieService.findMatchingMovieId();

      expect(result, 456);
    });

    test('findMatchingMovieId returns 0 when no match found', () async {
      mockMovieRepository.movieChoices = {123: 1};
      mockMovieRepository.usersMovieChoices = {456: 1};

      final result = await movieService.findMatchingMovieId();

      expect(result, 0);
    });

    test('findMatchingMovieId returns first match when multiple matches exist', () async {
      mockMovieRepository.movieChoices = {123: 1, 456: 1, 789: 1};
      mockMovieRepository.usersMovieChoices = {123: 1, 456: 1};

      final result = await movieService.findMatchingMovieId();

      // Should return the first matching key
      expect([123, 456].contains(result), true);
    });

    test('findMatchingMovieId throws exception when user not logged in', () async {
      mockProfileRepository.currentUserId = '';

      expect(
        () => movieService.findMatchingMovieId(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('User is not logged in'),
        )),
      );
    });
  });

  group('MovieService.deleteMovieChoicesByRoomId Tests', () {
    test('deleteMovieChoicesByRoomId calls repositories', () async {
      await movieService.deleteMovieChoicesByRoomId();

      expect(mockMovieRepository.deleteMovieChoicesCalled, true);
      expect(mockMatchRepository.deleteMatchesCalled, true);
    });
  });

  group('MovieService.validateMatchInCurrentRoom Tests', () {
    test('validateMatchInCurrentRoom returns true when room IDs match', () async {
      final match = Match(
        room_id: 'test-room-id',
        movie_id: 12345,
        match_count: 2,
      );

      final result = await movieService.validateMatchInCurrentRoom(match);

      expect(result, true);
    });

    test('validateMatchInCurrentRoom returns false when room IDs do not match', () async {
      final match = Match(
        room_id: 'different-room-id',
        movie_id: 12345,
        match_count: 2,
      );

      final result = await movieService.validateMatchInCurrentRoom(match);

      expect(result, false);
    });
  });

  group('MovieService.getTopMoviesByStreamingService Tests', () {
    test('getTopMoviesByStreamingService returns movies from repository', () async {
      mockMovieRepository.topMovies = [
        Movie(
          id: 1,
          title: 'Netflix Movie',
          overview: 'Overview',
          releaseDate: DateTime(2024),
        ),
        Movie(
          id: 2,
          title: 'Another Netflix Movie',
          overview: 'Overview 2',
          releaseDate: DateTime(2024),
        ),
      ];

      final result = await movieService.getTopMoviesByStreamingService('netflix');

      expect(result.length, 2);
      expect(result[0].title, 'Netflix Movie');
    });

    test('getTopMoviesByStreamingService returns empty list when no movies', () async {
      mockMovieRepository.topMovies = [];

      final result = await movieService.getTopMoviesByStreamingService('disney');

      expect(result, isEmpty);
    });
  });
}
