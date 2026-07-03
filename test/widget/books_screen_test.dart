import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:src/blocs/auth/auth_bloc.dart';
import 'package:src/blocs/auth/auth_event.dart';
import 'package:src/blocs/book/book_bloc.dart';
import 'package:src/blocs/book/book_event.dart';
import 'package:src/blocs/book/book_state.dart';
import 'package:src/screens/books_screen.dart';
import 'package:src/widgets/app_states.dart';

import '../helpers/mocks.mocks.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('[Widget Test] BooksScreen', () {
    late MockAuthService mockAuthService;
    late MockBookRepository mockBookRepository;
    late AuthBloc authBloc;
    late BookBloc bookBloc;

    final mockUser = createMockUserResponse();
    final mockBooks = [
      createMockBookResponse(id: 1, title: 'Flutter Basics', price: 99000),
      createMockBookResponse(id: 2, title: 'Dart In Action', price: 150000),
    ];

    setUp(() {
      mockAuthService = MockAuthService();
      mockBookRepository = MockBookRepository();
      when(mockAuthService.getProfile()).thenAnswer((_) async => mockUser);
      authBloc = AuthBloc(authService: mockAuthService)..add(AppStarted());
      bookBloc = BookBloc(bookRepository: mockBookRepository);
    });

    tearDown(() {
      authBloc.close();
      bookBloc.close();
    });

    testWidgets('TC-W05: Hiển thị LoadingState khi BookBloc đang tải sách', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          authBloc: authBloc,
          bookBloc: bookBloc,
          child: const BooksScreen(),
        ),
      );
      bookBloc.emit(BookLoading());
      await tester.pump();

      expect(find.byType(LoadingState), findsOneWidget);
    });

    testWidgets('TC-W06: Hiển thị EmptyState khi danh sách sách rỗng', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          authBloc: authBloc,
          bookBloc: bookBloc,
          child: const BooksScreen(),
        ),
      );
      bookBloc.emit(const BookLoaded([]));
      await tester.pump();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No books found'), findsOneWidget);
    });

    testWidgets('TC-W07: Hiển thị danh sách sách với tiêu đề và giá khi tải thành công', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          authBloc: authBloc,
          bookBloc: bookBloc,
          child: const BooksScreen(),
        ),
      );
      bookBloc.emit(BookLoaded(mockBooks));
      await tester.pump();

      expect(find.text('Flutter Basics'), findsOneWidget);
      expect(find.text('Dart In Action'), findsOneWidget);
      expect(find.text('99000 VND'), findsOneWidget);
      expect(find.text('150000 VND'), findsOneWidget);
    });

    testWidgets('TC-W08: Hiển thị ErrorState với thông báo lỗi khi tải sách thất bại', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          authBloc: authBloc,
          bookBloc: bookBloc,
          child: const BooksScreen(),
        ),
      );
      bookBloc.emit(const BookError('Failed to fetch books'));
      await tester.pump();

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text('Failed to fetch books'), findsOneWidget);
    });

    testWidgets('TC-W09: Nhập keyword vào thanh tìm kiếm gửi SearchBooks event', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          authBloc: authBloc,
          bookBloc: bookBloc,
          child: const BooksScreen(),
        ),
      );
      bookBloc.emit(BookLoaded(mockBooks));
      await tester.pump();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'flutter');
      await tester.pump();

      verify(mockBookRepository.searchBooks('flutter')).called(1);
    });
  });
}
