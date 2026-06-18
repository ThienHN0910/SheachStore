import '../core/api/api_client.dart';
import '../models/catalog_models.dart';

class CategoryService {
  CategoryService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<CategoryResponse>> getCategories() {
    return _apiClient.get(
      '/api/categories',
      (json) => (json as List<dynamic>)
          .map(
            (item) => CategoryResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Future<CategoryResponse> getCategory(int id) {
    return _apiClient.get(
      '/api/categories/$id',
      (json) => CategoryResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<CategoryResponse> createCategory(CategoryRequest request) {
    return _apiClient.post(
      '/api/categories',
      request.toJson(),
      (json) => CategoryResponse.fromJson(json as Map<String, dynamic>),
      authorized: true,
    );
  }

  Future<void> updateCategory(int id, CategoryRequest request) {
    return _apiClient.put(
      '/api/categories/$id',
      request.toJson(),
      (_) {},
      authorized: true,
    );
  }

  Future<void> deleteCategory(int id) {
    return _apiClient.delete('/api/categories/$id', authorized: true);
  }
}
