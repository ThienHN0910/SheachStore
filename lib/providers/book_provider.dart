import 'package:flutter/foundation.dart';
import '../models/catalog_models.dart';
import '../repositories/book_repository.dart';

class BookProvider extends ChangeNotifier {
  BookProvider({required BookRepository bookRepository})
      : _bookRepository = bookRepository;

  final BookRepository _bookRepository;

  List<BookResponse> _books = [];
  List<CategoryResponse> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BookResponse> get books => _books;
  List<CategoryResponse> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _books = await _bookRepository.getBooks();
      _extractCategories();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchBooks(String keyword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _books = await _bookRepository.searchBooks(keyword);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> filterByCategory(int categoryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _books = await _bookRepository.filterByCategory(categoryId);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void _extractCategories() {
    final unique = <int, String>{};
    for (final book in _books) {
      if (book.categoryName != null) {
        unique[book.categoryId] = book.categoryName!;
      }
    }
    _categories = unique.entries
        .map((e) => CategoryResponse(id: e.key, name: e.value, slug: ''))
        .toList();
  }
}
