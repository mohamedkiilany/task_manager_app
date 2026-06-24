// lib/features/projects/presentation/widgets/project_card.dart

import 'package:flutter/material.dart';
import '../../domain/models/project_model.dart';
import 'package:go_router/go_router.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;

  const ProjectCard({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isActive = project.status == 'Active';
    return Card(
      child: ListTile(
        title: Text(project.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(project.description, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Chip(
          label: Text(project.status),
          backgroundColor: isActive ? Colors.green[100] : Colors.grey[300],
        ),
        onTap: () => context.go('/home/project/${project.id}'),
      ),
    );
  }
}
