// lib/features/tasks/domain/models/task_model.dart

class TaskModel {
  final int id;
  final String title;
  final bool completed;
  final String status; // Done or Pending
  final String priority; // High, Medium, Low

  TaskModel({required this.id, required this.title, required this.completed, required this.status, required this.priority});

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] is int ? json['id'] : int.parse(json['id'].toString());
    final completed = json['completed'] == true || json['completed'] == 1;
    final status = completed ? 'Done' : 'Pending';
    final mod = id % 3;
    final priority = mod == 0 ? 'High' : (mod == 1 ? 'Medium' : 'Low');
    return TaskModel(id: id, title: json['title'] ?? '', completed: completed, status: status, priority: priority);
  }

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'completed': completed};
}
