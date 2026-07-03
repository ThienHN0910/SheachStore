import 'package:flutter_test/flutter_test.dart';
import 'package:src/models/cart_models.dart';

void main() {
  group('[Unit Test] Cart Models', () {
    group('CartItemRequest', () {
      test('TC-U08: toJson() serialize đúng bookId và quantity', () {
        // Arrange
        const request = CartItemRequest(bookId: 45, quantity: 3);
        // Act
        final json = request.toJson();
        // Assert
        expect(json, {'bookId': 45, 'quantity': 3});
      });
    });

    group('UpdateCartItemRequest', () {
      test('TC-U09: toJson() serialize đúng quantity', () {
        const request = UpdateCartItemRequest(quantity: 5);
        expect(request.toJson(), {'quantity': 5});
      });
    });

    group('CartItemResponse', () {
      test('TC-U10: fromJson() parse đúng khi bookTitle có giá trị', () {
        final json = {
          'id': 1,
          'bookId': 10,
          'bookTitle': 'Dart programming',
          'quantity': 2,
          'unitPrice': 15000,
          'lineTotal': 30000,
        };
        final response = CartItemResponse.fromJson(json);
        expect(response.id, 1);
        expect(response.bookId, 10);
        expect(response.bookTitle, 'Dart programming');
        expect(response.quantity, 2);
        expect(response.unitPrice, 15000.0);
        expect(response.lineTotal, 30000.0);
      });

      test('TC-U11: fromJson() parse đúng khi bookTitle là null', () {
        final json = {
          'id': 2,
          'bookId': 11,
          'bookTitle': null,
          'quantity': 1,
          'unitPrice': 20000.0,
          'lineTotal': 20000.0,
        };
        final response = CartItemResponse.fromJson(json);
        expect(response.bookTitle, isNull);
      });
    });

    group('CartResponse', () {
      test('TC-U12: fromJson() parse đúng nested items và totalAmount', () {
        final json = {
          'id': 100,
          'userId': 'user-999',
          'updatedAt': '2026-07-03T16:00:00.000Z',
          'items': [
            {
              'id': 1,
              'bookId': 10,
              'bookTitle': 'Book A',
              'quantity': 2,
              'unitPrice': 50000,
              'lineTotal': 100000,
            },
            {
              'id': 2,
              'bookId': 11,
              'bookTitle': 'Book B',
              'quantity': 1,
              'unitPrice': 70000,
              'lineTotal': 70000,
            }
          ],
          'totalAmount': 170000,
        };
        final response = CartResponse.fromJson(json);
        expect(response.id, 100);
        expect(response.userId, 'user-999');
        expect(response.updatedAt, DateTime.utc(2026, 7, 3, 16, 0, 0));
        expect(response.items.length, 2);
        expect(response.items[0].bookTitle, 'Book A');
        expect(response.items[1].bookTitle, 'Book B');
        expect(response.totalAmount, 170000.0);
      });
    });
  });
}
