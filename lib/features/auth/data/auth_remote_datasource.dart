// lib/features/auth/data/auth_remote_datasource.dart

import 'package:dio/dio.dart';
import '../domain/models/user_model.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/offline_manager.dart';

class AuthRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<UserModel?> login(String email, String password) async {
    try {
      final resp = await _dio.get(ApiConstants.users);
      if (resp.statusCode == 200) {
        final data = resp.data as List<dynamic>;
        final match = data.cast<Map<String, dynamic>>().firstWhere(
          (u) => (u['email'] ?? '').toString().toLowerCase() == email.toLowerCase(),
          orElse: () => {},
        );
        if (match.isNotEmpty) return UserModel.fromJson(match);
      }
      return null;
    } on DioException catch (e) {
      final msg = e.message ?? e.error?.toString() ?? 'Network error';
      if (msg.contains('Failed host lookup') || msg.contains('No address') || msg.contains('SocketException')) {
        // Fallback to offline simulated user
        // Mark app as offline so UI can show an indicator
        try {
          // avoid import side-effects if value notifier unavailable in some test envs
          // ignore: avoid_dynamic_calls
          (OfflineManager.instance).setOffline(true);
        } catch (_) {}
        return UserModel(id: 999, name: 'Offline User', email: email);
      }
      throw AppException(msg, code: e.response?.statusCode);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<UserModel> register(String name, String email, String password) async {
    try {
      final body = {'name': name, 'email': email};
      final resp = await _dio.post(ApiConstants.users, data: body);
      if (resp.statusCode == 201 || resp.statusCode == 200) {
        final map = resp.data as Map<String, dynamic>;
        // JSONPlaceholder returns an id; ensure defaults
        return UserModel.fromJson({
          'id': map['id'] ?? 0,
          'name': map['name'] ?? name,
          'email': map['email'] ?? email,
        });
      }
      throw AppException('Registration failed', code: resp.statusCode);
    } on DioException catch (e) {
      final msg = e.message ?? e.error?.toString() ?? 'Network error';
      if (msg.contains('Failed host lookup') || msg.contains('No address') || msg.contains('SocketException')) {
        // Simulate registration locally when offline
        return UserModel(id: 1000 + DateTime.now().millisecondsSinceEpoch % 1000, name: name, email: email);
      }
      throw AppException(msg, code: e.response?.statusCode);
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
