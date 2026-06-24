// lib/features/projects/domain/projects_repository.dart

import 'models/project_model.dart';

abstract class ProjectsRepository {
  Future<List<ProjectModel>> fetchProjects();
}
