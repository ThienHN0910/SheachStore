import '../core/api/api_client.dart';
import '../models/api_enums.dart';
import '../models/order_models.dart';

class OrderService {
  OrderService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<OrderResponse>> getOrders() {
    return _apiClient.get(
      '/api/orders',
      (json) => (json as List<dynamic>)
          .map((item) => OrderResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
      authorized: true,
    );
  }

  Future<List<OrderResponse>> getMyOrders() {
    return _apiClient.get(
      '/api/orders/mine',
      (json) => (json as List<dynamic>)
          .map((item) => OrderResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
      authorized: true,
    );
  }

  Future<OrderResponse> getOrder(int id) {
    return _apiClient.get(
      '/api/orders/$id',
      (json) => OrderResponse.fromJson(json as Map<String, dynamic>),
      authorized: true,
    );
  }

  Future<PayOsCheckoutResponse> createPayOsOrder(CreateOrderRequest request) {
    return _apiClient.post(
      '/api/orders/payos',
      request.toJson(),
      (json) => PayOsCheckoutResponse.fromJson(json as Map<String, dynamic>),
      authorized: true,
    );
  }

  Future<void> updateStatus(int id, OrderStatus status) {
    return _apiClient.patch(
      '/api/orders/$id/status',
      UpdateOrderStatusRequest(status: status).toJson(),
      (_) {},
      authorized: true,
    );
  }

  Future<void> deleteOrder(int id) {
    return _apiClient.delete('/api/orders/$id', authorized: true);
  }
}
