// lib/core/errors/app_exception.dart

class AppException implements Exception {
  final String message;
  final int? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}
