// lib/features/tasks/data/tasks_repository_impl.dart

import '../domain/tasks_repository.dart';
import '../domain/models/task_model.dart';
import 'tasks_remote_datasource.dart';

class TasksRepositoryImpl implements TasksRepository {
  final TasksRemoteDataSource _remote = TasksRemoteDataSource();

  @override
  Future<List<TaskModel>> getTasksByProject(int projectId) async => await _remote.getTasksByProject(projectId);

  @override
  Future<TaskModel?> updateTask(int taskId, bool completed) async => await _remote.updateTask(taskId, completed);

  @override
  Future<TaskModel?> createTask(String title, int projectId) async => await _remote.createTask(title, projectId);
}
