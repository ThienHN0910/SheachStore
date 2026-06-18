import '../core/api/api_client.dart';
import '../models/cart_models.dart';

class CartService {
  CartService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<CartResponse> getCart() {
    return _apiClient.get(
      '/api/cart',
      (json) => CartResponse.fromJson(json as Map<String, dynamic>),
      authorized: true,
    );
  }

  Future<CartResponse> addItem(CartItemRequest request) {
    return _apiClient.post(
      '/api/cart/items',
      request.toJson(),
      (json) => CartResponse.fromJson(json as Map<String, dynamic>),
      authorized: true,
    );
  }

  Future<void> updateItem(int itemId, UpdateCartItemRequest request) {
    return _apiClient.put(
      '/api/cart/items/$itemId',
      request.toJson(),
      (_) {},
      authorized: true,
    );
  }

  Future<void> removeItem(int itemId) {
    return _apiClient.delete('/api/cart/items/$itemId', authorized: true);
  }

  Future<void> clearCart() {
    return _apiClient.delete('/api/cart/items', authorized: true);
  }
}
