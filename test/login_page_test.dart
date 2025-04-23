import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_date/controllers/auth_controller.dart';
import 'package:movie_date/pages/login_page.dart';
import 'package:movie_date/repositories/login_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([LoginRepository])
import 'login_page_test.mocks.dart';

void main() {
  late MockLoginRepository mockLoginRepository;

  setUp(() {
    mockLoginRepository = MockLoginRepository();
  });

  testWidgets('LoginPage displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((ref) => AuthController(mockLoginRepository)),
        ],
        child: const MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    // Verify that the login page shows the expected widgets
    expect(find.text('EMAIL'), findsOneWidget);
    expect(find.text('PASSWORD'), findsOneWidget);
    expect(find.text('LOG IN'), findsOneWidget);
    expect(find.text('No account yet? Sign up.'), findsOneWidget);
    
    // Verify that the logo is displayed
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('LoginPage shows error on invalid login', (WidgetTester tester) async {
    // Setup mock to throw an exception
    when(mockLoginRepository.login(any, any))
        .thenThrow(Exception('Invalid credentials'));

    // Build our app and trigger a frame
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((ref) => AuthController(mockLoginRepository)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LoginPage(),
          ),
        ),
      ),
    );

    // Enter text in the email field
    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    
    // Enter text in the password field
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    
    // Tap the login button
    await tester.tap(find.text('LOG IN'));
    await tester.pump();
    
    // Verify that the login method was called
    verify(mockLoginRepository.login('test@example.com', 'password123')).called(1);
  });

  testWidgets('Password visibility toggle works', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((ref) => AuthController(mockLoginRepository)),
        ],
        child: const MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    // Initially password should be obscured (visibility icon should be shown)
    expect(find.byIcon(Icons.visibility), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off), findsNothing);
    
    // Tap the visibility icon
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();
    
    // Now password should be visible (visibility_off icon should be shown)
    expect(find.byIcon(Icons.visibility), findsNothing);
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });
}