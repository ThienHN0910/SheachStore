class ApiException implements Exception {
  const ApiException(this.message, {required this.statusCode, this.details});

  final String message;
  final int statusCode;
  final Object? details;

  @override
  String toString() {
    return 'ApiException($statusCode): $message';
  }
}
