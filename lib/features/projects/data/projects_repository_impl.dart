// lib/features/projects/data/projects_repository_impl.dart

import '../domain/projects_repository.dart';
import '../domain/models/project_model.dart';
import 'projects_remote_datasource.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsRemoteDataSource _remote = ProjectsRemoteDataSource();

  @override
  Future<List<ProjectModel>> fetchProjects() async {
    return await _remote.getProjects();
  }
}
