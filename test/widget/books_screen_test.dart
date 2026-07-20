import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:src/models/catalog_models.dart';
import 'package:src/providers/auth_provider.dart';
import 'package:src/providers/book_provider.dart';
import 'package:src/repositories/book_repository.dart';
import 'package:src/screens/books_screen.dart';
import 'package:src/widgets/app_states.dart';

import '../helpers/mocks.mocks.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('[Widget Test] BooksScreen', () {
    late MockAuthService mockAuthService;
    late MockBookService mockBookService;
    late AuthProvider authProvider;
    late BookProvider bookProvider;

    final mockUser = createMockUserResponse();
    final mockBooks = [
      createMockBookResponse(id: 1, title: 'Flutter Basics', price: 99000),
      createMockBookResponse(id: 2, title: 'Dart In Action', price: 150000),
    ];

    setUp(() {
      mockAuthService = MockAuthService();
      mockBookService = MockBookService();
      authProvider = AuthProvider(authService: mockAuthService);
      bookProvider = BookProvider(
        bookRepository: BookRepository(bookService: mockBookService),
      );
      when(mockAuthService.getProfile()).thenAnswer((_) async => mockUser);
    });

    /// Wraps [BooksScreen] with both AuthProvider and BookProvider.
    Widget buildApp() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<BookProvider>.value(value: bookProvider),
        ],
        child: const MaterialApp(home: BooksScreen()),
      );
    }

    testWidgets('TC-W05: Hiển thị LoadingState khi BookProvider đang tải sách', (WidgetTester tester) async {
      // Dùng Completer thay vì Future.delayed để không tạo timer treo
      final completer = Completer<List<BookResponse>>();
      when(mockBookService.getBooks()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildApp());
      await tester.pump(); // trigger post-frame callback → fetchBooks → isLoading = true

      expect(find.byType(LoadingState), findsOneWidget);

      // Hoàn thành future để cleanup timer
      completer.complete([]);
      await tester.pump();
    });

    testWidgets('TC-W06: Hiển thị EmptyState khi danh sách sách rỗng', (WidgetTester tester) async {
      when(mockBookService.getBooks()).thenAnswer((_) async => []);

      await tester.pumpWidget(buildApp());
      await tester.pump(); // start frame
      await tester.pump(); // after fetchBooks completes

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No books found'), findsOneWidget);
    });

    testWidgets('TC-W07: Hiển thị danh sách sách với tiêu đề và giá khi tải thành công', (WidgetTester tester) async {
      when(mockBookService.getBooks()).thenAnswer((_) async => mockBooks);

      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump();

      expect(find.text('Flutter Basics'), findsOneWidget);
      expect(find.text('Dart In Action'), findsOneWidget);
      expect(find.text('99000 VND'), findsOneWidget);
      expect(find.text('150000 VND'), findsOneWidget);
    });

    testWidgets('TC-W08: Hiển thị ErrorState với thông báo lỗi khi tải sách thất bại', (WidgetTester tester) async {
      when(mockBookService.getBooks()).thenThrow(Exception('Failed to fetch books'));

      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump();

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text('Exception: Failed to fetch books'), findsOneWidget);
    });

    testWidgets('TC-W09: Nhập keyword vào thanh tìm kiếm gọi searchBooks', (WidgetTester tester) async {
      when(mockBookService.getBooks()).thenAnswer((_) async => mockBooks);

      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'flutter');
      await tester.pump();
      await tester.pump();

      // searchBooks delegates to bookService.getBooks() (client-side filter)
      verify(mockBookService.getBooks()).called(greaterThanOrEqualTo(2));
    });
  });
}
