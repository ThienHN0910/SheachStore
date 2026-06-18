enum UserRole {
  admin('Admin'),
  customer('Customer');

  const UserRole(this.value);
  final String value;

  static UserRole fromJson(String value) {
    return UserRole.values.firstWhere((role) => role.value == value);
  }
}

enum OrderStatus {
  pending('Pending'),
  paid('Paid'),
  processing('Processing'),
  shipped('Shipped'),
  completed('Completed'),
  cancelled('Cancelled');

  const OrderStatus(this.value);
  final String value;

  static OrderStatus fromJson(String value) {
    return OrderStatus.values.firstWhere((status) => status.value == value);
  }
}

enum PaymentMethod {
  cashOnDelivery('CashOnDelivery'),
  bankTransfer('BankTransfer'),
  card('Card'),
  momo('Momo');

  const PaymentMethod(this.value);
  final String value;

  static PaymentMethod fromJson(String value) {
    return PaymentMethod.values.firstWhere((method) => method.value == value);
  }
}
