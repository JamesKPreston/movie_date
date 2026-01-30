// Widget tests for the Movie Date app.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movie_date/pages/login_page.dart';

void main() {
  testWidgets('LoginPage displays correctly', (WidgetTester tester) async {
    // Build the LoginPage wrapped in necessary providers
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const LoginPage(),
        ),
      ),
    );

    // Verify that the login page displays the app branding (RichText)
    expect(find.byType(RichText), findsWidgets);

    // Verify that email and password fields are present
    expect(find.text('EMAIL'), findsOneWidget);
    expect(find.text('PASSWORD'), findsOneWidget);

    // Verify that the login button is present
    expect(find.text('LOG IN'), findsOneWidget);

    // Verify that the sign up link is present
    expect(find.text('No account yet? Sign up.'), findsOneWidget);
  });

  testWidgets('LoginPage password visibility toggle works', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const LoginPage(),
        ),
      ),
    );

    // Initially password should be obscured (visibility icon shown)
    expect(find.byIcon(Icons.visibility), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off), findsNothing);

    // Tap the visibility icon to toggle
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();

    // Now password should be visible (visibility_off icon shown)
    expect(find.byIcon(Icons.visibility), findsNothing);
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });
}
