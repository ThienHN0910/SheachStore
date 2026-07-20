import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/book/book_bloc.dart';
import 'package:src/models/api_enums.dart';
import 'package:src/models/catalog_models.dart';
import 'package:src/models/user_models.dart';
import 'package:src/models/cart_models.dart';
import 'package:src/models/order_models.dart';
import 'package:src/models/review_models.dart';
import 'package:src/providers/auth_provider.dart';
import 'package:src/providers/book_provider.dart';
import 'package:src/repositories/book_repository.dart';
import 'package:src/services/auth_service.dart';

UserResponse createMockUserResponse({
  String id = 'user-123',
  String email = 'test@example.com',
  String fullName = 'Test User',
  UserRole role = UserRole.customer,
  int loyaltyPoints = 100,
  DateTime? createdAt,
}) {
  return UserResponse(
    id: id,
    email: email,
    fullName: fullName,
    role: role,
    loyaltyPoints: loyaltyPoints,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
  );
}

BookResponse createMockBookResponse({
  int id = 1,
  String title = 'Mock Book Title',
  int authorId = 10,
  String authorName = 'Mock Author',
  int categoryId = 2,
  String categoryName = 'Mock Category',
  double price = 99000.0,
  int stock = 20,
  String coverUrl = 'http://example.com/cover.jpg',
  String description = 'Mock book description.',
}) {
  return BookResponse(
    id: id,
    title: title,
    authorId: authorId,
    authorName: authorName,
    categoryId: categoryId,
    categoryName: categoryName,
    price: price,
    stock: stock,
    coverUrl: coverUrl,
    description: description,
  );
}

CartItemResponse createMockCartItemResponse({
  int id = 1,
  int bookId = 1,
  String bookTitle = 'Mock Book Title',
  int quantity = 2,
  double unitPrice = 99000.0,
  double lineTotal = 198000.0,
}) {
  return CartItemResponse(
    id: id,
    bookId: bookId,
    bookTitle: bookTitle,
    quantity: quantity,
    unitPrice: unitPrice,
    lineTotal: lineTotal,
  );
}

CartResponse createMockCartResponse({
  int id = 1,
  String userId = 'user-123',
  DateTime? updatedAt,
  List<CartItemResponse>? items,
  double totalAmount = 198000.0,
}) {
  return CartResponse(
    id: id,
    userId: userId,
    updatedAt: updatedAt ?? DateTime(2026, 1, 1),
    items: items ?? [createMockCartItemResponse()],
    totalAmount: totalAmount,
  );
}

OrderItemResponse createMockOrderItemResponse({
  int id = 1,
  int bookId = 1,
  String bookTitle = 'Mock Book Title',
  int quantity = 2,
  double unitPrice = 99000.0,
  double lineTotal = 198000.0,
}) {
  return OrderItemResponse(
    id: id,
    bookId: bookId,
    bookTitle: bookTitle,
    quantity: quantity,
    unitPrice: unitPrice,
    lineTotal: lineTotal,
  );
}

OrderResponse createMockOrderResponse({
  int id = 1,
  String userId = 'user-123',
  String userFullName = 'Test User',
  double totalAmount = 198000.0,
  OrderStatus status = OrderStatus.pending,
  String shippingAddress = '123 Test St',
  DateTime? createdAt,
  List<OrderItemResponse>? items,
}) {
  return OrderResponse(
    id: id,
    userId: userId,
    userFullName: userFullName,
    totalAmount: totalAmount,
    status: status,
    shippingAddress: shippingAddress,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
    items: items ?? [createMockOrderItemResponse()],
  );
}

ReviewResponse createMockReviewResponse({
  int id = 1,
  String userId = 'user-123',
  String userFullName = 'Test User',
  int bookId = 1,
  String bookTitle = 'Mock Book Title',
  int rating = 5,
  String comment = 'Great book!',
  DateTime? createdAt,
}) {
  return ReviewResponse(
    id: id,
    userId: userId,
    userFullName: userFullName,
    bookId: bookId,
    bookTitle: bookTitle,
    rating: rating,
    comment: comment,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
  );
}

/// Creates a test app wrapping [child] with the necessary providers.
///
/// - Provide [authBloc] / [bookBloc] when you need BLoC context (e.g. widget
///   tests that test against BLoC state).
/// - Provide [authProvider] / [bookProvider] when the screen under test reads
///   from Provider (e.g. AuthScreen, BooksScreen).
/// - Provide [authService] + [bookRepository] as a shorthand: the helper will
///   build AuthProvider and BookProvider automatically from them.
Widget createTestApp({
  required Widget child,
  // BLoC providers (for screens that consume BLoC)
  AuthBloc? authBloc,
  BookBloc? bookBloc,
  // Provider providers (for screens that consume Provider)
  AuthProvider? authProvider,
  BookProvider? bookProvider,
  // Shorthand: build providers from services/repos
  AuthService? authService,
  BookRepository? bookRepository,
}) {
  final effectiveAuthProvider =
      authProvider ?? (authService != null ? AuthProvider(authService: authService) : null);
  final effectiveBookProvider =
      bookProvider ?? (bookRepository != null ? BookProvider(bookRepository: bookRepository) : null);

  Widget app = MaterialApp(home: child);

  // Wrap with BLoC providers if supplied
  if (authBloc != null || bookBloc != null) {
    final blocs = <BlocProvider>[
      if (authBloc != null) BlocProvider<AuthBloc>.value(value: authBloc),
      if (bookBloc != null) BlocProvider<BookBloc>.value(value: bookBloc),
    ];
    app = MaterialApp(
      home: MultiBlocProvider(
        providers: blocs,
        child: Scaffold(body: child),
      ),
    );
  }

  // Wrap with Provider providers if supplied (supports both BLoC + Provider)
  if (effectiveAuthProvider != null || effectiveBookProvider != null) {
    final providers = [
      if (effectiveAuthProvider != null)
        ChangeNotifierProvider<AuthProvider>.value(value: effectiveAuthProvider),
      if (effectiveBookProvider != null)
        ChangeNotifierProvider<BookProvider>.value(value: effectiveBookProvider),
    ];

    if (authBloc != null || bookBloc != null) {
      // Both BLoC and Provider: wrap the BLoC app in Provider
      app = MultiProvider(providers: providers, child: app);
    } else {
      app = MultiProvider(
        providers: providers,
        child: MaterialApp(home: child),
      );
    }
  }

  return app;
}
