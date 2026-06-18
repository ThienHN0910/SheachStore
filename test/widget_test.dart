import 'package:flutter_test/flutter_test.dart';
import 'package:src/main.dart';

void main() {
  testWidgets('renders auth screen when no token exists', (tester) async {
    await tester.pumpWidget(
      SheachStoreApp(initialTokenFuture: Future<String?>.value(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('SheachStore'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
