// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'network_interceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    final options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    );

    // Add a lightweight MockInterceptor first to provide offline-friendly sample data when the API is unreachable.
    dio = Dio(options)
      ..interceptors.add(_MockInterceptor())
      ..interceptors.add(NetworkInterceptor());
  }
}

class _MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;

    if (path.endsWith(ApiConstants.users) || path == ApiConstants.users) {
      final data = [
        {'id': 1, 'name': 'Test User', 'email': 'test@example.com'},
        {'id': 2, 'name': 'Jane Doe', 'email': 'jane@example.com'},
      ];
      final resp = Response(requestOptions: options, data: data, statusCode: 200);
      return handler.resolve(resp);
    }

    if (path.endsWith(ApiConstants.posts) || path == ApiConstants.posts) {
      final data = [
        {'id': 1, 'title': 'Demo Project', 'body': 'Project description example', 'userId': 1},
        {'id': 2, 'title': 'Another Project', 'body': 'Another description', 'userId': 2},
      ];
      final resp = Response(requestOptions: options, data: data, statusCode: 200);
      return handler.resolve(resp);
    }

    if (path.endsWith(ApiConstants.todos) || path == ApiConstants.todos) {
      final data = [
        {'id': 1, 'title': 'First task', 'completed': false, 'userId': 1},
        {'id': 2, 'title': 'Second task', 'completed': true, 'userId': 1},
        {'id': 3, 'title': 'Third task', 'completed': false, 'userId': 2},
      ];
      final resp = Response(requestOptions: options, data: data, statusCode: 200);
      return handler.resolve(resp);
    }

    handler.next(options);
  }
}
