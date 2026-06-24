// lib/features/projects/data/projects_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../domain/models/project_model.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/offline_manager.dart';

class ProjectsRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<List<ProjectModel>> getProjects() async {
    try {
      final resp = await _dio.get(ApiConstants.posts);
      if (resp.statusCode == 200) {
        final data = resp.data as List<dynamic>;
        return data.cast<Map<String, dynamic>>().map((m) => ProjectModel.fromJson(m)).toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.message ?? e.error?.toString() ?? 'Network error';
      if (msg.contains('Failed host lookup') || msg.contains('No address') || msg.contains('SocketException')) {
        // Return offline mock projects when network fails
        // Mark offline for UI
        try {
          OfflineManager.instance.setOffline(true);
        } catch (_) {}
        return [
          ProjectModel(id: 9001, title: 'Offline Project A', description: 'Fallback project - offline', status: 'Active'),
          ProjectModel(id: 9002, title: 'Offline Project B', description: 'Fallback project - offline', status: 'Completed'),
        ];
      }
      throw AppException(msg, code: e.response?.statusCode);
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
