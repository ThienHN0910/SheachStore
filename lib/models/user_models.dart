import 'api_enums.dart';

class UserResponse {
  const UserResponse({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.loyaltyPoints,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final int loyaltyPoints;
  final DateTime createdAt;

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      role: UserRole.fromJson(json['role'] as String),
      loyaltyPoints: json['loyaltyPoints'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
