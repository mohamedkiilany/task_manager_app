// lib/features/projects/domain/models/project_model.dart

class ProjectModel {
  final int id;
  final String title;
  final String description;
  final String status; // 'Active' or 'Completed'

  ProjectModel({required this.id, required this.title, required this.description, required this.status});

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] is int ? json['id'] : int.parse(json['id'].toString());
    final status = (id % 2 == 1) ? 'Active' : 'Completed';
    return ProjectModel(
      id: id,
      title: json['title'] ?? '',
      description: json['body'] ?? json['description'] ?? '',
      status: status,
    );
  }
}
