import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:src/repositories/book_repository.dart';

import '../../helpers/mocks.mocks.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('[Unit Test] BookRepository', () {
    late MockBookService mockBookService;
    late BookRepository bookRepository;

    final mockBooks = [
      createMockBookResponse(id: 1, title: 'Flutter Basics', authorName: 'John', categoryId: 10),
      createMockBookResponse(id: 2, title: 'Dart In Action', authorName: 'Alice', categoryId: 11),
      createMockBookResponse(id: 3, title: 'Advanced Flutter', authorName: 'John', categoryId: 10),
    ];

    setUp(() {
      mockBookService = MockBookService();
      bookRepository = BookRepository(bookService: mockBookService);
    });

    group('getBooks', () {
      test('TC-U43: getBooks() trả về danh sách sách từ BookService', () async {
        // Arrange
        when(mockBookService.getBooks()).thenAnswer((_) async => mockBooks);
        // Act
        final result = await bookRepository.getBooks();
        // Assert
        expect(result, mockBooks);
        verify(mockBookService.getBooks()).called(1);
      });
    });

    group('searchBooks', () {
      test('TC-U44: searchBooks("") trả về tất cả sách khi keyword rỗng', () async {
        when(mockBookService.getBooks()).thenAnswer((_) async => mockBooks);
        final result = await bookRepository.searchBooks('');
        expect(result, mockBooks);
      });

      test('TC-U45: searchBooks("flutter") lọc đúng theo title (case-insensitive)', () async {
        when(mockBookService.getBooks()).thenAnswer((_) async => mockBooks);
        final result = await bookRepository.searchBooks('flutter');
        expect(result.length, 2);
        expect(result[0].title, 'Flutter Basics');
        expect(result[1].title, 'Advanced Flutter');
      });

      test('TC-U46: searchBooks("alice") lọc đúng theo authorName (case-insensitive)', () async {
        when(mockBookService.getBooks()).thenAnswer((_) async => mockBooks);
        final result = await bookRepository.searchBooks('alice');
        expect(result.length, 1);
        expect(result[0].title, 'Dart In Action');
      });

      test('TC-U47: searchBooks("javascript") trả về danh sách rỗng khi không tìm thấy', () async {
        when(mockBookService.getBooks()).thenAnswer((_) async => mockBooks);
        final result = await bookRepository.searchBooks('javascript');
        expect(result, isEmpty);
      });
    });

    group('filterByCategory', () {
      test('TC-U48: filterByCategory(10) trả về sách đúng categoryId', () async {
        when(mockBookService.getBooks()).thenAnswer((_) async => mockBooks);
        final result = await bookRepository.filterByCategory(10);
        expect(result.length, 2);
        expect(result[0].title, 'Flutter Basics');
        expect(result[1].title, 'Advanced Flutter');
      });

      test('TC-U49: filterByCategory(999) trả về danh sách rỗng khi không có sách', () async {
        when(mockBookService.getBooks()).thenAnswer((_) async => mockBooks);
        final result = await bookRepository.filterByCategory(999);
        expect(result, isEmpty);
      });
    });
  });
}
