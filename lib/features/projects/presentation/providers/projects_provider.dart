// lib/features/projects/presentation/providers/projects_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/project_model.dart';
import '../../domain/projects_repository.dart';
import '../../data/projects_repository_impl.dart';

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) => ProjectsRepositoryImpl());
final projectsProvider = AsyncNotifierProvider<ProjectsNotifier, List<ProjectModel>>(ProjectsNotifier.new);

class ProjectsNotifier extends AsyncNotifier<List<ProjectModel>> {
  late final ProjectsRepository _repo;

  @override
  Future<List<ProjectModel>> build() async {
    _repo = ref.read(projectsRepositoryProvider);
    // start with empty list; actual fetch happens when screen opens
    return [];
  }

  Future<void> fetchProjects() async {
    state = const AsyncValue.loading();
    try {
      final projects = await _repo.fetchProjects();
      state = AsyncValue.data(projects);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async => await fetchProjects();
}
