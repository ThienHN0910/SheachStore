import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:src/blocs/auth/auth_bloc.dart';
import 'package:src/screens/auth_screen.dart';

import '../helpers/mocks.mocks.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('[Widget Test] AuthScreen', () {
    late MockAuthService mockAuthService;
    late AuthBloc authBloc;

    setUp(() {
      mockAuthService = MockAuthService();
      authBloc = AuthBloc(authService: mockAuthService);
    });

    tearDown(() {
      authBloc.close();
    });

    testWidgets('TC-W01: Hiển thị đầy đủ form Login, nút Login và nút Google Sign In khi mở app', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestApp(
          authBloc: authBloc,
          child: AuthScreen(onAuthenticated: () {}),
        ),
      );
      await tester.pump();

      expect(find.text('SheachStore'), findsOneWidget);
      expect(find.text('Sign in to continue shopping'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
      expect(find.text('Need an account? Register'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Full name'), findsNothing);
    });

    testWidgets('TC-W02: Hiển thị lỗi validation khi nhấn Login với form trống', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestApp(
          authBloc: authBloc,
          child: AuthScreen(onAuthenticated: () {}),
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('TC-W03: Chuyển sang form Register và hiển thị lỗi validation cho các field mới', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestApp(
          authBloc: authBloc,
          child: AuthScreen(onAuthenticated: () {}),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Need an account? Register'));
      await tester.pumpAndSettle();

      expect(find.text('Create your customer account'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Full name'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Confirm Password'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Create account'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pump();

      expect(find.text('Full name is required'), findsOneWidget);
    });

    testWidgets('TC-W04: Nhấn nút Google Sign In gửi GoogleSignInRequested event', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestApp(
          authBloc: authBloc,
          child: AuthScreen(onAuthenticated: () {}),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Sign in with Google'));
      await tester.pump();

      verify(mockAuthService.signInWithGoogle()).called(1);
    });
  });
}
