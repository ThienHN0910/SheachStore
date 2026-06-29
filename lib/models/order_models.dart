import 'api_enums.dart';

class CreateOrderItemRequest {
  const CreateOrderItemRequest({required this.bookId, required this.quantity});

  final int bookId;
  final int quantity;

  Map<String, dynamic> toJson() {
    return {'bookId': bookId, 'quantity': quantity};
  }
}

class CreateOrderRequest {
  const CreateOrderRequest({
    required this.shippingAddress,
    required this.items,
  });

  final String shippingAddress;
  final List<CreateOrderItemRequest> items;

  Map<String, dynamic> toJson() {
    return {
      'shippingAddress': shippingAddress,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class UpdateOrderStatusRequest {
  const UpdateOrderStatusRequest({required this.status});

  final OrderStatus status;

  Map<String, dynamic> toJson() {
    return {'status': status.value};
  }
}

class OrderItemResponse {
  const OrderItemResponse({
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

  factory OrderItemResponse.fromJson(Map<String, dynamic> json) {
    return OrderItemResponse(
      id: json['id'] as int,
      bookId: json['bookId'] as int,
      bookTitle: json['bookTitle'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      lineTotal: (json['lineTotal'] as num).toDouble(),
    );
  }
}

class OrderResponse {
  const OrderResponse({
    required this.id,
    required this.userId,
    this.userFullName,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.createdAt,
    required this.items,
  });

  final int id;
  final String userId;
  final String? userFullName;
  final double totalAmount;
  final OrderStatus status;
  final String shippingAddress;
  final DateTime createdAt;
  final List<OrderItemResponse> items;

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      id: json['id'] as int,
      userId: json['userId'] as String,
      userFullName: json['userFullName'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: OrderStatus.fromJson(json['status'] as String),
      shippingAddress: json['shippingAddress'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      items: (json['items'] as List<dynamic>)
          .map(
            (item) => OrderItemResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class PayOsCheckoutResponse {
  const PayOsCheckoutResponse({
    required this.orderId,
    required this.checkoutUrl,
    this.qrCodeUrl,
  });

  final int orderId;
  final String checkoutUrl;
  final String? qrCodeUrl;

  factory PayOsCheckoutResponse.fromJson(Map<String, dynamic> json) {
    return PayOsCheckoutResponse(
      orderId: json['orderId'] as int,
      checkoutUrl: json['checkoutUrl'] as String,
      qrCodeUrl: json['qrCodeUrl'] as String?,
    );
  }
}
