import '../core/api/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/api_enums.dart';
import '../models/auth_models.dart';

class AuthService {
  AuthService({ApiClient? apiClient, TokenStorage? tokenStorage})
    : _apiClient = apiClient ?? ApiClient(tokenStorage: tokenStorage),
      _tokenStorage = tokenStorage ?? TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.customer,
  }) async {
    final response = await _apiClient.post(
      '/api/auth/register',
      RegisterRequest(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      ).toJson(),
      (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );

    await _tokenStorage.saveToken(response.token);
    return response;
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/api/auth/login',
      LoginRequest(email: email, password: password).toJson(),
      (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );

    await _tokenStorage.saveToken(response.token);
    return response;
  }

  Future<void> logout() {
    return _tokenStorage.clearToken();
  }
}
