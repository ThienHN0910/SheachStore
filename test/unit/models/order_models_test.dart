import 'package:flutter_test/flutter_test.dart';
import 'package:src/models/api_enums.dart';
import 'package:src/models/order_models.dart';

void main() {
  group('[Unit Test] Order Models', () {
    group('CreateOrderItemRequest', () {
      test('TC-U23: toJson() serialize đúng bookId và quantity', () {
        const request = CreateOrderItemRequest(bookId: 1, quantity: 2);
        expect(request.toJson(), {'bookId': 1, 'quantity': 2});
      });
    });

    group('CreateOrderRequest', () {
      test('TC-U24: toJson() serialize đúng nested items list', () {
        const request = CreateOrderRequest(
          shippingAddress: '123 Main St',
          items: [
            CreateOrderItemRequest(bookId: 1, quantity: 2),
            CreateOrderItemRequest(bookId: 2, quantity: 1),
          ],
        );
        expect(request.toJson(), {
          'shippingAddress': '123 Main St',
          'items': [
            {'bookId': 1, 'quantity': 2},
            {'bookId': 2, 'quantity': 1},
          ],
        });
      });
    });

    group('UpdateOrderStatusRequest', () {
      test('TC-U25: toJson() serialize đúng OrderStatus.value', () {
        const request = UpdateOrderStatusRequest(status: OrderStatus.paid);
        expect(request.toJson(), {'status': 'Paid'});
      });
    });

    group('OrderItemResponse', () {
      test('TC-U26: fromJson() parse đúng tất cả fields', () {
        final json = {
          'id': 10,
          'bookId': 1,
          'bookTitle': 'Sách A',
          'quantity': 3,
          'unitPrice': 50000,
          'lineTotal': 150000,
        };
        final response = OrderItemResponse.fromJson(json);
        expect(response.id, 10);
        expect(response.bookId, 1);
        expect(response.bookTitle, 'Sách A');
        expect(response.quantity, 3);
        expect(response.unitPrice, 50000.0);
        expect(response.lineTotal, 150000.0);
      });
    });

    group('OrderResponse', () {
      test('TC-U27: fromJson() parse đúng OrderStatus, DateTime và nested items', () {
        final json = {
          'id': 100,
          'userId': 'user-1',
          'userFullName': 'Customer A',
          'totalAmount': 150000,
          'status': 'Pending',
          'shippingAddress': '123 Main St',
          'createdAt': '2026-07-03T16:00:00.000Z',
          'items': [
            {
              'id': 10,
              'bookId': 1,
              'bookTitle': 'Sách A',
              'quantity': 3,
              'unitPrice': 50000,
              'lineTotal': 150000,
            }
          ],
        };
        final response = OrderResponse.fromJson(json);
        expect(response.id, 100);
        expect(response.status, OrderStatus.pending);
        expect(response.createdAt, DateTime.utc(2026, 7, 3, 16, 0, 0));
        expect(response.items.length, 1);
        expect(response.items[0].bookTitle, 'Sách A');
      });
    });

    group('PayOsCheckoutResponse', () {
      test('TC-U28: fromJson() parse đúng khi có qrCodeUrl', () {
        final json = {
          'orderId': 200,
          'checkoutUrl': 'https://payos.vn/pay/12345',
          'qrCodeUrl': 'https://payos.vn/qr/12345',
        };
        final response = PayOsCheckoutResponse.fromJson(json);
        expect(response.orderId, 200);
        expect(response.checkoutUrl, 'https://payos.vn/pay/12345');
        expect(response.qrCodeUrl, 'https://payos.vn/qr/12345');
      });

      test('TC-U29: fromJson() parse đúng khi qrCodeUrl là null', () {
        final json = {
          'orderId': 200,
          'checkoutUrl': 'https://payos.vn/pay/12345',
          'qrCodeUrl': null,
        };
        final response = PayOsCheckoutResponse.fromJson(json);
        expect(response.qrCodeUrl, isNull);
      });
    });
  });
}
