import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:src/blocs/auth/auth_bloc.dart';
import 'package:src/blocs/book/book_bloc.dart';
import 'package:src/models/api_enums.dart';
import 'package:src/models/catalog_models.dart';
import 'package:src/models/user_models.dart';
import 'package:src/models/cart_models.dart';
import 'package:src/models/order_models.dart';
import 'package:src/models/review_models.dart';

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

Widget createTestApp({
  required Widget child,
  AuthBloc? authBloc,
  BookBloc? bookBloc,
}) {
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        if (authBloc != null) BlocProvider<AuthBloc>.value(value: authBloc),
        if (bookBloc != null) BlocProvider<BookBloc>.value(value: bookBloc),
      ],
      child: Scaffold(body: child),
    ),
  );
}

