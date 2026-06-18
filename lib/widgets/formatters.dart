import '../models/api_enums.dart';

String formatMoney(double value) {
  return '${value.toStringAsFixed(0)} VND';
}

String formatDate(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day/$month/${local.year}';
}

String paymentMethodLabel(PaymentMethod method) {
  return switch (method) {
    PaymentMethod.cashOnDelivery => 'Cash on delivery',
    PaymentMethod.bankTransfer => 'Bank transfer',
    PaymentMethod.card => 'Card',
    PaymentMethod.momo => 'Momo',
  };
}

String orderStatusLabel(OrderStatus status) {
  return switch (status) {
    OrderStatus.pending => 'Pending',
    OrderStatus.paid => 'Paid',
    OrderStatus.processing => 'Processing',
    OrderStatus.shipped => 'Shipped',
    OrderStatus.completed => 'Completed',
    OrderStatus.cancelled => 'Cancelled',
  };
}
