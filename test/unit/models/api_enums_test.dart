import 'package:flutter_test/flutter_test.dart';
import 'package:src/models/api_enums.dart';

void main() {
  group('[Unit Test] API Enums', () {
    group('UserRole', () {
      test('TC-U01: fromJson("Admin") trả về UserRole.admin', () {
        expect(UserRole.fromJson('Admin'), UserRole.admin);
      });

      test('TC-U02: fromJson("Customer") trả về UserRole.customer', () {
        expect(UserRole.fromJson('Customer'), UserRole.customer);
      });

      test('TC-U03: fromJson("InvalidRole") ném StateError', () {
        expect(() => UserRole.fromJson('InvalidRole'), throwsStateError);
      });
    });

    group('OrderStatus', () {
      test('TC-U04: fromJson("Pending") trả về OrderStatus.pending', () {
        expect(OrderStatus.fromJson('Pending'), OrderStatus.pending);
      });

      test('TC-U05: fromJson("Paid") trả về OrderStatus.paid', () {
        expect(OrderStatus.fromJson('Paid'), OrderStatus.paid);
      });

      test('TC-U06: fromJson("Cancelled") trả về OrderStatus.cancelled', () {
        expect(OrderStatus.fromJson('Cancelled'), OrderStatus.cancelled);
      });

      test('TC-U07: fromJson("InvalidStatus") ném StateError', () {
        expect(() => OrderStatus.fromJson('InvalidStatus'), throwsStateError);
      });
    });
  });
}
