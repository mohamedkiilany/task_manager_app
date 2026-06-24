// lib/features/tasks/presentation/widgets/task_card.dart

import 'package:flutter/material.dart';
import '../../domain/models/task_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tasks_provider.dart';

class TaskCard extends ConsumerWidget {
  final TaskModel task;
  final int projectId;

  const TaskCard({Key? key, required this.task, required this.projectId}) : super(key: key);

  Color _priorityColor(String p) {
    switch (p) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: task.completed,
          onChanged: task.completed
              ? null
              : (v) => ref.read(tasksProvider(projectId).notifier).markAsDone(task.id),
        ),
        title: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Row(children: [
          Chip(label: Text(task.status)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: _priorityColor(task.priority).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Text(task.priority, style: TextStyle(color: _priorityColor(task.priority))),
          ),
        ]),
      ),
    );
  }
}

