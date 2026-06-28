import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../core/api/api_client.dart';
import '../models/auth_models.dart';
import '../models/user_models.dart';

class AuthService {
  AuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    ApiClient? apiClient,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _apiClient = apiClient ?? ApiClient();

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final ApiClient _apiClient;

  // Lấy profile từ Backend SQL (nguồn duy nhất cho role)
  Future<UserResponse> _fetchProfileFromApi() async {
    return await _apiClient.get(
      '/api/auth/profile',
      (json) => UserResponse.fromJson(json as Map<String, dynamic>),
      authorized: true,
    );
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await userCredential.user!.updateDisplayName(fullName);

    // Backend sẽ tự tạo User record trong SQL khi nhận được token
    final user = await _fetchProfileFromApi();
    return AuthResponse(user: user);
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = await _fetchProfileFromApi();
    return AuthResponse(user: user);
  }

  Future<AuthResponse> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign In was cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _firebaseAuth.signInWithCredential(credential);

    // Backend sẽ tự tạo User record nếu chưa có
    final user = await _fetchProfileFromApi();
    return AuthResponse(user: user);
  }

  Future<void> logout() async {
    await Future.wait([
      _googleSignIn.signOut(),
      _firebaseAuth.signOut(),
    ]);
  }

  Future<UserResponse> getProfile() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }
    return _fetchProfileFromApi();
  }
}
