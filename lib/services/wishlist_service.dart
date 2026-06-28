import '../core/api/api_client.dart';
import '../models/catalog_models.dart';

class WishlistService {
  WishlistService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<BookResponse>> getWishlist() {
    return _apiClient.get(
      '/api/wishlist',
      (json) => (json as List<dynamic>)
          .map((item) => BookResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
      authorized: true,
    );
  }

  Future<void> addToWishlist(int bookId) {
    return _apiClient.post(
      '/api/wishlist',
      {'bookId': bookId},
      (_) {},
      authorized: true,
    );
  }

  Future<void> removeFromWishlist(int bookId) {
    return _apiClient.delete(
      '/api/wishlist/$bookId',
      authorized: true,
    );
  }

  Future<bool> checkWishlist(int bookId) {
    return _apiClient.get(
      '/api/wishlist/check/$bookId',
      (json) => json as bool,
      authorized: true,
    );
  }
}
