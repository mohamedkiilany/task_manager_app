// lib/features/tasks/presentation/providers/tasks_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/task_model.dart';
import '../../domain/tasks_repository.dart';
import '../../data/tasks_repository_impl.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) => TasksRepositoryImpl());
final tasksProvider = StateNotifierProvider.family<TasksNotifier, AsyncValue<List<TaskModel>>, int>((ref, projectId) {
  final repo = ref.read(tasksRepositoryProvider);
  return TasksNotifier(repo, projectId);
});

class TasksNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final TasksRepository _repo;
  final int projectId;

  TasksNotifier(this._repo, this.projectId) : super(const AsyncValue.loading()) {
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _repo.getTasksByProject(projectId);
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsDone(int taskId) async {
    try {
      final updated = await _repo.updateTask(taskId, true);
      if (updated != null) {
        state = state.whenData((list) => list.map((t) => t.id == taskId ? updated : t).toList());
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> addTask(String title) async {
    try {
      final created = await _repo.createTask(title, projectId);
      if (created != null) {
        state = state.whenData((list) => [created, ...list]);
      }
    } catch (e) {
      // ignore
    }
  }
}
