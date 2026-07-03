import 'package:flutter_test/flutter_test.dart';
import 'package:src/models/api_enums.dart';
import 'package:src/models/user_models.dart';

void main() {
  group('[Unit Test] User Models', () {
    group('UserResponse', () {
      test('TC-U34: fromJson() parse đúng id, email, fullName, role, loyaltyPoints, createdAt', () {
        // Arrange
        final json = {
          'id': 'user-123',
          'email': 'user@sheachstore.com',
          'fullName': 'Nguyen Van A',
          'role': 'Customer',
          'loyaltyPoints': 250,
          'createdAt': '2026-07-03T16:00:00.000Z',
        };
        // Act
        final response = UserResponse.fromJson(json);
        // Assert
        expect(response.id, 'user-123');
        expect(response.email, 'user@sheachstore.com');
        expect(response.fullName, 'Nguyen Van A');
        expect(response.role, UserRole.customer);
        expect(response.loyaltyPoints, 250);
        expect(response.createdAt, DateTime.utc(2026, 7, 3, 16, 0, 0));
      });
    });
  });
}
