import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_date/api/filters/movie.dart';
import 'package:movie_date/models/member_model.dart';
import 'package:movie_date/models/profile_model.dart';
import 'package:movie_date/models/room_model.dart';
import 'package:movie_date/pages/main_page.dart';
import 'package:movie_date/providers/profile_repository_provider.dart';
import 'package:movie_date/providers/room_service_provider.dart';
import 'package:movie_date/repositories/members_repository.dart';
import 'package:movie_date/repositories/profile_repository.dart';
import 'package:movie_date/repositories/room_repository.dart';
import 'package:movie_date/services/room_service.dart';

// Mock implementations
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
  bool shouldThrowOnJoin = false;

  @override
  Future<Room> getRoomByRoomId(String id) async {
    return Room(
      id: id,
      filters: [MovieFilters(page: 1)],
      room_code: 'ABC123',
      match_threshold: 2,
    );
  }

  @override
  Future<void> addRoom(Room room) async {}

  @override
  Future<String> getRoomCodeById(String id) async => 'ABC123';

  @override
  Future<String> getRoomIdByRoomCode(String roomCode) async {
    if (shouldThrowOnJoin) {
      throw Exception('Invalid room code');
    }
    return 'room-id-123';
  }

  @override
  Future<void> deleteRoom(Room room) async {}

  @override
  Future<void> updateRoom(Room room) async {}
}

class MockMembersRepository implements MembersRepository {
  @override
  Future<List<String>> getRoomMembers(String roomId) async {
    return ['test@example.com', 'other@example.com'];
  }

  @override
  Future<void> addMember(Member member) async {}

  @override
  Future<String> getRoomIdByUserId(String userId) async => 'room-id-123';
}

class MockRoomService extends RoomService {
  bool joinRoomCalled = false;
  String? lastRoomCode;
  String? lastUserId;
  bool shouldThrowOnJoin = false;

  MockRoomService(
    MockRoomRepository roomRepo,
    MockMembersRepository membersRepo,
    MockProfileRepository profileRepo,
  ) : super(roomRepo, membersRepo, profileRepo);

  @override
  Future<void> joinRoom(String roomCode, String userId) async {
    if (shouldThrowOnJoin) {
      throw Exception('Invalid room code');
    }
    joinRoomCalled = true;
    lastRoomCode = roomCode;
    lastUserId = userId;
  }
}

void main() {
  late MockProfileRepository mockProfileRepository;
  late MockRoomRepository mockRoomRepository;
  late MockMembersRepository mockMembersRepository;
  late MockRoomService mockRoomService;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    mockRoomRepository = MockRoomRepository();
    mockMembersRepository = MockMembersRepository();
    mockRoomService = MockRoomService(
      mockRoomRepository,
      mockMembersRepository,
      mockProfileRepository,
    );
  });

  Widget createTestWidget({Widget? child}) {
    return ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(mockProfileRepository),
        roomServiceProvider.overrideWithValue(mockRoomService),
      ],
      child: MaterialApp(
        home: child ?? const MainPage(),
      ),
    );
  }

  group('MainPage Widget Tests', () {
    testWidgets('renders AppBar with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Movie Date'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('AppBar has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, Colors.black);
      expect(appBar.centerTitle, true);
    });

    testWidgets('renders NavigationBar with correct destinations', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Join Room'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('NavigationBar has correct number of destinations', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationDestination), findsNWidgets(3));
    });

    testWidgets('renders navigation icons correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.door_front_door_outlined), findsOneWidget);
      expect(find.byIcon(Icons.search_outlined), findsOneWidget);
    });

    testWidgets('has a drawer', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsWidgets);

      // MainPage should have a drawer
      final scaffold = tester.widget<Scaffold>(scaffoldFinder.first);
      expect(scaffold.drawer, isNotNull);
    });

    testWidgets('renders PageView for page navigation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('PageView has NeverScrollableScrollPhysics', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.physics, isA<NeverScrollableScrollPhysics>());
    });

    testWidgets('Home destination is selected by default', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navigationBar.selectedIndex, 0);
    });

    testWidgets('NavigationBar has correct indicator color', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navigationBar.indicatorColor, Colors.white70);
    });
  });

  group('MainPage Navigation Tests', () {
    testWidgets('tapping Search navigates to correct page', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      final navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navigationBar.selectedIndex, 2);
    });

    testWidgets('tapping Home stays on home page', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      final navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navigationBar.selectedIndex, 0);
    });
  });

  group('Join Room Dialog Tests', () {
    testWidgets('tapping Join Room shows dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Join Room'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Join Room'), findsNWidgets(2)); // One in nav, one in dialog
    });

    testWidgets('Join Room dialog has correct UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Join Room'));
      await tester.pumpAndSettle();

      expect(find.text('Enter Room Code'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Cancel button closes the dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Join Room'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('TextField in dialog accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Join Room'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'abc123');
      await tester.pumpAndSettle();

      // UpperCaseTextFormatter should convert to uppercase
      expect(find.text('ABC123'), findsOneWidget);
    });

    testWidgets('TextField has OutlineInputBorder decoration', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Join Room'));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.border, isA<OutlineInputBorder>());
      expect(textField.decoration?.labelText, 'Enter Room Code');
    });

    testWidgets('Join Room dialog does not change selected index', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initial selected index should be 0
      var navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navigationBar.selectedIndex, 0);

      await tester.tap(find.text('Join Room'));
      await tester.pumpAndSettle();

      // Selected index should still be 0 after showing dialog
      navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navigationBar.selectedIndex, 0);
    });

    testWidgets('Submit button attempts to join room with entered code', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Join Room'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'TESTCODE');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(mockRoomService.joinRoomCalled, true);
      expect(mockRoomService.lastRoomCode, 'TESTCODE');
    });

    testWidgets('invalid room code shows error snackbar', (WidgetTester tester) async {
      mockRoomService.shouldThrowOnJoin = true;

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Join Room'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'INVALID');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid room code'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('UpperCaseTextFormatter Tests', () {
    test('converts lowercase to uppercase', () {
      final formatter = UpperCaseTextFormatter();
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(
        text: 'abc',
        selection: TextSelection.collapsed(offset: 3),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, 'ABC');
      expect(result.selection, const TextSelection.collapsed(offset: 3));
    });

    test('preserves uppercase text', () {
      final formatter = UpperCaseTextFormatter();
      const oldValue = TextEditingValue(text: 'AB');
      const newValue = TextEditingValue(
        text: 'ABC',
        selection: TextSelection.collapsed(offset: 3),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, 'ABC');
    });

    test('converts mixed case to uppercase', () {
      final formatter = UpperCaseTextFormatter();
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(
        text: 'AbCdEf',
        selection: TextSelection.collapsed(offset: 6),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, 'ABCDEF');
    });

    test('preserves selection position', () {
      final formatter = UpperCaseTextFormatter();
      const oldValue = TextEditingValue(text: 'ab');
      const newValue = TextEditingValue(
        text: 'abc',
        selection: TextSelection.collapsed(offset: 3),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.selection, const TextSelection.collapsed(offset: 3));
    });

    test('handles empty string', () {
      final formatter = UpperCaseTextFormatter();
      const oldValue = TextEditingValue(text: 'a');
      const newValue = TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '');
    });

    test('handles alphanumeric input', () {
      final formatter = UpperCaseTextFormatter();
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(
        text: 'abc123xyz',
        selection: TextSelection.collapsed(offset: 9),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, 'ABC123XYZ');
    });
  });

  group('MainPage Static Methods', () {
    test('route() returns MaterialPageRoute', () {
      final route = MainPage.route();

      expect(route, isA<MaterialPageRoute>());
    });

    testWidgets('route() creates MainPage widget', (WidgetTester tester) async {
      final route = MainPage.route();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(mockProfileRepository),
            roomServiceProvider.overrideWithValue(mockRoomService),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return route.buildPage(context, Animation<double>.fromValueListenable(
                  ValueNotifier(1.0),
                ), Animation<double>.fromValueListenable(
                  ValueNotifier(1.0),
                ));
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MainPage), findsOneWidget);
    });
  });

  group('MainPage Scaffold Structure', () {
    testWidgets('Scaffold has correct structure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('body contains NotificationListener', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(NotificationListener<ScrollNotification>), findsOneWidget);
    });
  });
}
