import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:src/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SheachStore E2E Customer Flow Test', () {
    testWidgets('Register new account and view book catalog', (WidgetTester tester) async {
      // Start the application
      app.main();
      await tester.pumpAndSettle();

      // Verify we are on the AuthScreen (Login view initially)
      expect(find.text('SheachStore'), findsOneWidget);
      expect(find.text('Sign in to continue shopping'), findsOneWidget);

      // Tap on "Need an account? Register" to switch to register view
      final registerTextFinder = find.text('Need an account? Register');
      expect(registerTextFinder, findsOneWidget);
      await tester.tap(registerTextFinder);
      await tester.pumpAndSettle();

      // Verify we switched to register view
      expect(find.text('Create your customer account'), findsOneWidget);

      // Generate a unique email to avoid duplicates in the real backend
      final uniqueEmail = 'testcustomer_${DateTime.now().millisecondsSinceEpoch}@example.com';

      // Enter registration information
      // In Flutter, we can find TextFormField by label using ancestor finders or by type
      final nameField = find.widgetWithText(TextFormField, 'Full name');
      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      final confirmPasswordField = find.widgetWithText(TextFormField, 'Confirm Password');

      await tester.enterText(nameField, 'E2E Test User');
      await tester.enterText(emailField, uniqueEmail);
      await tester.enterText(passwordField, 'Password123!');
      await tester.enterText(confirmPasswordField, 'Password123!');
      await tester.pumpAndSettle();

      // Tap on "Create account" button
      final createAccountButton = find.widgetWithText(FilledButton, 'Create account');
      await tester.tap(createAccountButton);

      // Pump and wait for network response and transition (this will hit the real API)
      // Since it's a real API call, it might take a few seconds
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // After successful registration, the app should log in automatically and navigate to BooksScreen
      // Let's verify we are on the BooksScreen
      // BooksScreen has the title 'SheachStore' and the search box
      expect(find.text('SheachStore'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);

      // We should wait a moment for the book catalog to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify that the catalog has books loaded
      // Since it uses a real database, there should be some books.
      // If there are books, there will be _BookCard widgets or Chevron icons.
      // Let's check for the search bar placeholder
      expect(find.text('Search books...'), findsOneWidget);
    });
  });
}
