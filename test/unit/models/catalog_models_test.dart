import 'package:flutter_test/flutter_test.dart';
import 'package:src/models/catalog_models.dart';

void main() {
  group('[Unit Test] Catalog Models', () {
    group('CategoryRequest', () {
      test('TC-U13: toJson() serialize đúng name và slug', () {
        const request = CategoryRequest(name: 'Novel', slug: 'novel');
        expect(request.toJson(), {'name': 'Novel', 'slug': 'novel'});
      });
    });

    group('CategoryResponse', () {
      test('TC-U14: fromJson() parse đúng id, name, slug', () {
        final json = {'id': 1, 'name': 'Novel', 'slug': 'novel'};
        final response = CategoryResponse.fromJson(json);
        expect(response.id, 1);
        expect(response.name, 'Novel');
        expect(response.slug, 'novel');
      });
    });

    group('AuthorRequest', () {
      test('TC-U15: toJson() serialize đúng khi có bio', () {
        const request = AuthorRequest(name: 'John Doe', bio: 'A great author');
        expect(request.toJson(), {'name': 'John Doe', 'bio': 'A great author'});
      });

      test('TC-U16: toJson() serialize đúng khi bio là null', () {
        const request = AuthorRequest(name: 'John Doe', bio: null);
        expect(request.toJson(), {'name': 'John Doe', 'bio': null});
      });
    });

    group('AuthorResponse', () {
      test('TC-U17: fromJson() parse đúng khi có bio', () {
        final json = {'id': 10, 'name': 'John Doe', 'bio': 'A writer'};
        final response = AuthorResponse.fromJson(json);
        expect(response.id, 10);
        expect(response.name, 'John Doe');
        expect(response.bio, 'A writer');
      });

      test('TC-U18: fromJson() parse đúng khi bio là null', () {
        final json = {'id': 10, 'name': 'John Doe', 'bio': null};
        final response = AuthorResponse.fromJson(json);
        expect(response.bio, isNull);
      });
    });

    group('BookRequest', () {
      test('TC-U19: toJson() serialize đúng khi có coverUrl và description', () {
        const request = BookRequest(
          title: 'Flutter Guide',
          authorId: 2,
          categoryId: 3,
          price: 120000.0,
          stock: 10,
          coverUrl: 'http://image.jpg',
          description: 'A complete guide',
        );
        expect(request.toJson(), {
          'title': 'Flutter Guide',
          'authorId': 2,
          'categoryId': 3,
          'price': 120000.0,
          'stock': 10,
          'coverUrl': 'http://image.jpg',
          'description': 'A complete guide',
        });
      });

      test('TC-U20: toJson() serialize đúng khi coverUrl và description là null', () {
        const request = BookRequest(
          title: 'Flutter Guide',
          authorId: 2,
          categoryId: 3,
          price: 120000.0,
          stock: 10,
          coverUrl: null,
          description: null,
        );
        final json = request.toJson();
        expect(json['coverUrl'], isNull);
        expect(json['description'], isNull);
      });
    });

    group('BookResponse', () {
      test('TC-U21: fromJson() parse đúng tất cả fields', () {
        final json = {
          'id': 1,
          'title': 'Flutter Guide',
          'authorId': 2,
          'authorName': 'Author A',
          'categoryId': 3,
          'categoryName': 'Tech',
          'price': 120000.0,
          'stock': 10,
          'coverUrl': 'http://image.jpg',
          'description': 'A complete guide',
        };
        final response = BookResponse.fromJson(json);
        expect(response.id, 1);
        expect(response.title, 'Flutter Guide');
        expect(response.authorName, 'Author A');
        expect(response.categoryName, 'Tech');
        expect(response.price, 120000.0);
        expect(response.stock, 10);
      });

      test('TC-U22: fromJson() parse đúng khi các field optional là null', () {
        final json = {
          'id': 1,
          'title': 'Flutter Guide',
          'authorId': 2,
          'authorName': null,
          'categoryId': 3,
          'categoryName': null,
          'price': 120000,
          'stock': 10,
          'coverUrl': null,
          'description': null,
        };
        final response = BookResponse.fromJson(json);
        expect(response.authorName, isNull);
        expect(response.categoryName, isNull);
        expect(response.coverUrl, isNull);
        expect(response.description, isNull);
        expect(response.price, 120000.0);
      });
    });
  });
}
