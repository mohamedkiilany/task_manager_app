import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/features/projects/presentation/providers/projects_provider.dart';
import 'package:task_manager_app/features/projects/domain/models/project_model.dart';
import 'package:task_manager_app/features/projects/domain/projects_repository.dart';

class FakeProjectsRepository implements ProjectsRepository {
  @override
  Future<List<ProjectModel>> fetchProjects() async {
    return [
      ProjectModel(id: 1, title: 'P1', description: 'd', status: 'Active'),
      ProjectModel(id: 2, title: 'P2', description: 'd', status: 'Completed'),
    ];
  }
}

void main() {
  test('projectsProvider fetchProjects returns list', () async {
    final fake = FakeProjectsRepository();
    final container = ProviderContainer(overrides: [projectsRepositoryProvider.overrideWithValue(fake)]);
    final notifier = container.read(projectsProvider.notifier);

    await notifier.fetchProjects();
    final state = container.read(projectsProvider);
    expect(state.asData?.value.length, 2);
    container.dispose();
  });
}
