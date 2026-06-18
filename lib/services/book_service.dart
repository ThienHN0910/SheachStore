import '../core/api/api_client.dart';
import '../models/catalog_models.dart';

class BookService {
  BookService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<BookResponse>> getBooks() {
    return _apiClient.get(
      '/api/books',
      (json) => (json as List<dynamic>)
          .map((item) => BookResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<BookResponse> getBook(int id) {
    return _apiClient.get(
      '/api/books/$id',
      (json) => BookResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BookResponse> createBook(BookRequest request) {
    return _apiClient.post(
      '/api/books',
      request.toJson(),
      (json) => BookResponse.fromJson(json as Map<String, dynamic>),
      authorized: true,
    );
  }

  Future<void> updateBook(int id, BookRequest request) {
    return _apiClient.put(
      '/api/books/$id',
      request.toJson(),
      (_) {},
      authorized: true,
    );
  }

  Future<void> deleteBook(int id) {
    return _apiClient.delete('/api/books/$id', authorized: true);
  }
}
