// lib/features/tasks/domain/tasks_repository.dart

import 'models/task_model.dart';

abstract class TasksRepository {
  Future<List<TaskModel>> getTasksByProject(int projectId);
  Future<TaskModel?> updateTask(int taskId, bool completed);
  Future<TaskModel?> createTask(String title, int projectId);
}
