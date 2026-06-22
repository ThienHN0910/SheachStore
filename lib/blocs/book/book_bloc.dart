import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/book_repository.dart';
import 'book_event.dart';
import 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final BookRepository _bookRepository;

  BookBloc({required BookRepository bookRepository})
      : _bookRepository = bookRepository,
        super(BookInitial()) {
    on<FetchBooks>(_onFetchBooks);
    on<SearchBooks>(_onSearchBooks);
    on<FilterByCategory>(_onFilterByCategory);
  }

  Future<void> _onFetchBooks(FetchBooks event, Emitter<BookState> emit) async {
    emit(BookLoading());
    try {
      final books = await _bookRepository.getBooks();
      emit(BookLoaded(books));
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onSearchBooks(SearchBooks event, Emitter<BookState> emit) async {
    emit(BookLoading());
    try {
      final books = await _bookRepository.searchBooks(event.keyword);
      emit(BookLoaded(books));
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onFilterByCategory(FilterByCategory event, Emitter<BookState> emit) async {
    emit(BookLoading());
    try {
      final books = await _bookRepository.filterByCategory(event.categoryId);
      emit(BookLoaded(books));
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }
}
