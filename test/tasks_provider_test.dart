import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:task_manager_app/features/tasks/domain/models/task_model.dart';
import 'package:task_manager_app/features/tasks/domain/tasks_repository.dart';

class FakeTasksRepository implements TasksRepository {
  @override
  Future<List<TaskModel>> getTasksByProject(int projectId) async {
    return [
      TaskModel(id: 1, title: 'T1', completed: false, status: 'Pending', priority: 'Low'),
      TaskModel(id: 2, title: 'T2', completed: true, status: 'Done', priority: 'High'),
    ];
  }

  @override
  Future<TaskModel?> updateTask(int taskId, bool completed) async {
    return TaskModel(id: taskId, title: 'Updated', completed: completed, status: completed ? 'Done' : 'Pending', priority: 'Low');
  }

  @override
  Future<TaskModel?> createTask(String title, int projectId) async {
    return TaskModel(id: 99, title: title, completed: false, status: 'Pending', priority: 'Medium');
  }
}

void main() {
  test('tasksProvider fetchTasks and addTask work', () async {
    final fake = FakeTasksRepository();
    final container = ProviderContainer(overrides: [tasksRepositoryProvider.overrideWithValue(fake)]);

    final provider = tasksProvider(1);
    final notifier = container.read(provider.notifier);

    await notifier.fetchTasks();
    var state = container.read(provider);
    expect(state.asData?.value.length, 2);

    await notifier.addTask('New Task');
    state = container.read(provider);
    expect(state.asData?.value.first.title, 'New Task');

    await notifier.markAsDone(1);
    state = container.read(provider);
    expect(state.asData?.value.any((t) => t.id == 1 && t.completed), true);

    container.dispose();
  });
}
