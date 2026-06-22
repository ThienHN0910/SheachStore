import '../models/catalog_models.dart';
import '../services/book_service.dart';

class BookRepository {
  final BookService _bookService;

  BookRepository({BookService? bookService})
      : _bookService = bookService ?? BookService();

  Future<List<BookResponse>> getBooks() async {
    return await _bookService.getBooks();
  }

  // Giả lập search trên client hoặc gọi API nếu backend hỗ trợ
  Future<List<BookResponse>> searchBooks(String keyword) async {
    final allBooks = await _bookService.getBooks();
    if (keyword.isEmpty) return allBooks;
    
    return allBooks.where((book) => 
      book.title.toLowerCase().contains(keyword.toLowerCase()) ||
      (book.authorName?.toLowerCase().contains(keyword.toLowerCase()) ?? false)
    ).toList();
  }

  Future<List<BookResponse>> filterByCategory(int categoryId) async {
    final allBooks = await _bookService.getBooks();
    return allBooks.where((book) => book.categoryId == categoryId).toList();
  }
}
