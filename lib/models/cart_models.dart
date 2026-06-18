class CartItemRequest {
  const CartItemRequest({required this.bookId, required this.quantity});

  final int bookId;
  final int quantity;

  Map<String, dynamic> toJson() {
    return {'bookId': bookId, 'quantity': quantity};
  }
}

class UpdateCartItemRequest {
  const UpdateCartItemRequest({required this.quantity});

  final int quantity;

  Map<String, dynamic> toJson() {
    return {'quantity': quantity};
  }
}

class CartItemResponse {
  const CartItemResponse({
    required this.id,
    required this.bookId,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.bookTitle,
  });

  final int id;
  final int bookId;
  final String? bookTitle;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  factory CartItemResponse.fromJson(Map<String, dynamic> json) {
    return CartItemResponse(
      id: json['id'] as int,
      bookId: json['bookId'] as int,
      bookTitle: json['bookTitle'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      lineTotal: (json['lineTotal'] as num).toDouble(),
    );
  }
}

class CartResponse {
  const CartResponse({
    required this.id,
    required this.userId,
    required this.updatedAt,
    required this.items,
    required this.totalAmount,
  });

  final int id;
  final String userId;
  final DateTime updatedAt;
  final List<CartItemResponse> items;
  final double totalAmount;

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      id: json['id'] as int,
      userId: json['userId'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      items: (json['items'] as List<dynamic>)
          .map(
            (item) => CartItemResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }
}
