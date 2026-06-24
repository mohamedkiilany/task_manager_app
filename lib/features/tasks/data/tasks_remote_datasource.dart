// lib/features/tasks/data/tasks_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../domain/models/task_model.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/offline_manager.dart';

class TasksRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<List<TaskModel>> getTasksByProject(int projectId) async {
    try {
      final resp = await _dio.get(ApiConstants.todos);
      if (resp.statusCode == 200) {
        final data = resp.data as List<dynamic>;
        // JSONPlaceholder: filter by userId == projectId or take first items
        final filtered = data.cast<Map<String, dynamic>>().where((m) {
          final uid = m['userId'];
          if (uid == null) return false;
          return uid is int ? uid == projectId : uid.toString() == projectId.toString();
        }).toList();
        final list = filtered.map((m) => TaskModel.fromJson(m)).toList();
        if (list.isNotEmpty) return list;
        // fallback: take first 8 todos
        return data.cast<Map<String, dynamic>>().take(8).map((m) => TaskModel.fromJson(m)).toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.message ?? e.error?.toString() ?? 'Network error';
      if (msg.contains('Failed host lookup') || msg.contains('No address') || msg.contains('SocketException')) {
        // Mark offline for UI
        try {
          OfflineManager.instance.setOffline(true);
        } catch (_) {}
        // Return offline mock tasks for the project
        return List.generate(5, (i) {
          final completed = i % 2 == 0;
          return TaskModel(id: 8000 + i, title: 'Offline Task ${i + 1}', completed: completed, status: completed ? 'Done' : 'Pending', priority: 'Low');
        });
      }
      throw AppException(msg, code: e.response?.statusCode);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<TaskModel?> updateTask(int taskId, bool completed) async {
    try {
      final resp = await _dio.put('${ApiConstants.todos}/$taskId', data: {'completed': completed});
      if (resp.statusCode == 200) {
        return TaskModel.fromJson(resp.data as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      final msg = e.message ?? e.error?.toString() ?? 'Network error';
      if (msg.contains('Failed host lookup') || msg.contains('No address') || msg.contains('SocketException')) {
        // Mark offline for UI
        try { OfflineManager.instance.setOffline(true); } catch (_) {}
        // Simulate update locally when offline
        final status = completed ? 'Done' : 'Pending';
        return TaskModel(id: taskId, title: 'Offline Task (updated)', completed: completed, status: status, priority: 'Low');
      }
      throw AppException(msg, code: e.response?.statusCode);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<TaskModel?> createTask(String title, int projectId) async {
    try {
      final resp = await _dio.post(ApiConstants.todos, data: {'title': title, 'completed': false, 'userId': projectId});
      if (resp.statusCode == 201 || resp.statusCode == 200) {
        final map = resp.data as Map<String, dynamic>;
        return TaskModel.fromJson(map);
      }
      return null;
    } on DioException catch (e) {
      final msg = e.message ?? e.error?.toString() ?? 'Network error';
      if (msg.contains('Failed host lookup') || msg.contains('No address') || msg.contains('SocketException')) {
        // Mark offline for UI
        try { OfflineManager.instance.setOffline(true); } catch (_) {}
        // Simulate created task locally when offline
        final id = 8100 + (DateTime.now().millisecondsSinceEpoch % 1000);
        return TaskModel(id: id, title: title, completed: false, status: 'Pending', priority: 'Low');
      }
      throw AppException(msg, code: e.response?.statusCode);
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
