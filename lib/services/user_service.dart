import '../core/api/api_client.dart';
import '../models/user_models.dart';

class UserService {
  UserService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<UserResponse>> getUsers() {
    return _apiClient.get(
      '/api/auth/users',
      (json) => (json as List<dynamic>)
          .map((item) => UserResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
      authorized: true,
    );
  }

  Future<void> updateUserRole(String userId, String role) {
    return _apiClient.put(
      '/api/auth/users/$userId/role',
      {'role': role},
      (_) {},
      authorized: true,
    );
  }
}
