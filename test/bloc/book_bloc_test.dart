import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../blocs/book/book_bloc.dart';
import '../blocs/book/book_event.dart';
import '../blocs/book/book_state.dart';
import '../helpers/mocks.mocks.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('[BLoC Test] BookBloc', () {
    late MockBookRepository mockBookRepository;
    late BookBloc bookBloc;

    final mockBooks = [
      createMockBookResponse(id: 1, title: 'Book 1'),
      createMockBookResponse(id: 2, title: 'Book 2'),
    ];

    setUp(() {
      mockBookRepository = MockBookRepository();
      bookBloc = BookBloc(bookRepository: mockBookRepository);
    });

    tearDown(() {
      bookBloc.close();
    });

    test('TC-B09: Trạng thái ban đầu là BookInitial', () {
      expect(bookBloc.state, equals(BookInitial()));
    });

    blocTest<BookBloc, BookState>(
      'TC-B10: FetchBooks → BookLoading → BookLoaded khi tải sách thành công',
      build: () {
        when(mockBookRepository.getBooks()).thenAnswer((_) async => mockBooks);
        return bookBloc;
      },
      act: (bloc) => bloc.add(FetchBooks()),
      expect: () => [BookLoading(), BookLoaded(mockBooks)],
      verify: (_) {
        verify(mockBookRepository.getBooks()).called(1);
      },
    );

    blocTest<BookBloc, BookState>(
      'TC-B11: FetchBooks → BookLoading → BookError khi API lỗi',
      build: () {
        when(mockBookRepository.getBooks()).thenThrow(Exception('API error'));
        return bookBloc;
      },
      act: (bloc) => bloc.add(FetchBooks()),
      expect: () => [BookLoading(), const BookError('Exception: API error')],
    );

    blocTest<BookBloc, BookState>(
      'TC-B12: SearchBooks("flutter") → BookLoading → BookLoaded với kết quả lọc',
      build: () {
        when(mockBookRepository.searchBooks('flutter'))
            .thenAnswer((_) async => [mockBooks[0]]);
        return bookBloc;
      },
      act: (bloc) => bloc.add(const SearchBooks('flutter')),
      expect: () => [BookLoading(), BookLoaded([mockBooks[0]])],
    );

    blocTest<BookBloc, BookState>(
      'TC-B13: SearchBooks → BookLoading → BookError khi tìm kiếm lỗi',
      build: () {
        when(mockBookRepository.searchBooks('flutter'))
            .thenThrow(Exception('Search error'));
        return bookBloc;
      },
      act: (bloc) => bloc.add(const SearchBooks('flutter')),
      expect: () => [BookLoading(), const BookError('Exception: Search error')],
    );

    blocTest<BookBloc, BookState>(
      'TC-B14: FilterByCategory(5) → BookLoading → BookLoaded với kết quả lọc',
      build: () {
        when(mockBookRepository.filterByCategory(5))
            .thenAnswer((_) async => mockBooks);
        return bookBloc;
      },
      act: (bloc) => bloc.add(const FilterByCategory(5)),
      expect: () => [BookLoading(), BookLoaded(mockBooks)],
    );

    blocTest<BookBloc, BookState>(
      'TC-B15: FilterByCategory → BookLoading → BookError khi lọc lỗi',
      build: () {
        when(mockBookRepository.filterByCategory(5))
            .thenThrow(Exception('Filter error'));
        return bookBloc;
      },
      act: (bloc) => bloc.add(const FilterByCategory(5)),
      expect: () => [BookLoading(), const BookError('Exception: Filter error')],
    );
  });
}
