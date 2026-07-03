import 'package:mockito/annotations.dart';
import 'package:src/services/auth_service.dart';
import 'package:src/services/book_service.dart';
import 'package:src/repositories/book_repository.dart';
import 'package:src/services/cart_service.dart';
import 'package:src/services/wishlist_service.dart';
import 'package:src/services/order_service.dart';
import 'package:src/services/review_service.dart';

@GenerateMocks([
  AuthService,
  BookService,
  BookRepository,
  CartService,
  WishlistService,
  OrderService,
  ReviewService,
])
void main() {}
