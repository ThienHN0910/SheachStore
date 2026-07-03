import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:src/blocs/auth/auth_bloc.dart';
import 'package:src/screens/auth_screen.dart';

import 'helpers/mocks.mocks.dart';
import 'helpers/test_helpers.dart';

void main() {
  group('[Widget Test] SheachStoreApp – Initial Launch', () {
    testWidgets('TC-W10: Hiển thị màn hình Auth với nút Login khi chưa đăng nhập', (tester) async {
      // Arrange – tạo AuthBloc với mock service (chưa đăng nhập)
      final mockAuthService = MockAuthService();
      final authBloc = AuthBloc(authService: mockAuthService);

      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Act
      await tester.pumpWidget(
        createTestApp(
          authBloc: authBloc,
          child: AuthScreen(onAuthenticated: () {}),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('SheachStore'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);

      authBloc.close();
    });
  });
}
