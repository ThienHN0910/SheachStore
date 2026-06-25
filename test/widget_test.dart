import 'package:flutter_test/flutter_test.dart';
import 'package:src/main.dart';

void main() {
  testWidgets('renders auth screen when no token exists', (tester) async {
    await tester.pumpWidget(
      const SheachStoreApp(),
    );
    await tester.pumpAndSettle();

    expect(find.text('SheachStore'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
