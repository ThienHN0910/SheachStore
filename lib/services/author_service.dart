import '../core/api/api_client.dart';
import '../models/catalog_models.dart';

class AuthorService {
  AuthorService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<AuthorResponse>> getAuthors() {
    return _apiClient.get(
      '/api/authors',
      (json) => (json as List<dynamic>)
          .map((item) => AuthorResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<AuthorResponse> getAuthor(int id) {
    return _apiClient.get(
      '/api/authors/$id',
      (json) => AuthorResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<AuthorResponse> createAuthor(AuthorRequest request) {
    return _apiClient.post(
      '/api/authors',
      request.toJson(),
      (json) => AuthorResponse.fromJson(json as Map<String, dynamic>),
      authorized: true,
    );
  }

  Future<void> updateAuthor(int id, AuthorRequest request) {
    return _apiClient.put(
      '/api/authors/$id',
      request.toJson(),
      (_) {},
      authorized: true,
    );
  }

  Future<void> deleteAuthor(int id) {
    return _apiClient.delete('/api/authors/$id', authorized: true);
  }
}
