import 'package:flutter_test/flutter_test.dart';
import 'package:src/models/review_models.dart';

void main() {
  group('[Unit Test] Review Models', () {
    group('ReviewRequest', () {
      test('TC-U30: toJson() serialize đúng khi có comment', () {
        const request = ReviewRequest(bookId: 1, rating: 5, comment: 'Awesome!');
        expect(request.toJson(), {'bookId': 1, 'rating': 5, 'comment': 'Awesome!'});
      });

      test('TC-U31: toJson() serialize đúng khi comment là null', () {
        const request = ReviewRequest(bookId: 1, rating: 4, comment: null);
        expect(request.toJson(), {'bookId': 1, 'rating': 4, 'comment': null});
      });
    });

    group('ReviewResponse', () {
      test('TC-U32: fromJson() parse đúng tất cả fields', () {
        final json = {
          'id': 10,
          'userId': 'user-123',
          'bookId': 1,
          'rating': 5,
          'createdAt': '2026-07-03T16:00:00.000Z',
          'userFullName': 'Jane Doe',
          'bookTitle': 'Dart Programming',
          'comment': 'Loved it!',
        };
        final response = ReviewResponse.fromJson(json);
        expect(response.id, 10);
        expect(response.userId, 'user-123');
        expect(response.rating, 5);
        expect(response.userFullName, 'Jane Doe');
        expect(response.bookTitle, 'Dart Programming');
        expect(response.comment, 'Loved it!');
        expect(response.createdAt, DateTime.utc(2026, 7, 3, 16, 0, 0));
      });

      test('TC-U33: fromJson() parse đúng khi các field optional là null', () {
        final json = {
          'id': 10,
          'userId': 'user-123',
          'bookId': 1,
          'rating': 5,
          'createdAt': '2026-07-03T16:00:00.000Z',
          'userFullName': null,
          'bookTitle': null,
          'comment': null,
        };
        final response = ReviewResponse.fromJson(json);
        expect(response.userFullName, isNull);
        expect(response.bookTitle, isNull);
        expect(response.comment, isNull);
      });
    });
  });
}
