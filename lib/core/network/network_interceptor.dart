// lib/core/network/network_interceptor.dart

import 'package:dio/dio.dart';
// Use DioException where possible for newer Dio versions
import '../utils/secure_storage.dart';

class NetworkInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await SecureStorage.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // ignore storage errors
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        await SecureStorage.deleteToken();
        // Navigation to login should be handled by the app (GoRouter redirect)
      } catch (_) {}
    }
    handler.next(err);
  }
}
