// lib/features/tasks/presentation/screens/project_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/task_model.dart';
import '../providers/tasks_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/add_task_bottom_sheet.dart';
import '../../../projects/domain/models/project_model.dart';
import 'package:task_manager_app/shared/widgets/loading_widget.dart';
import 'package:task_manager_app/shared/widgets/error_widget.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  final ProjectModel project;
  const ProjectDetailsScreen({Key? key, required this.project}) : super(key: key);

  @override
  ConsumerState<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tasksProvider(widget.project.id).notifier).fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tasksProvider(widget.project.id));

    return Scaffold(
      appBar: AppBar(title: Text(widget.project.title)),
      body: state.when(
        data: (tasks) {
          if (tasks.isEmpty) return Center(child: Text('No tasks found'));
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: tasks.length,
            itemBuilder: (context, i) => TaskCard(task: tasks[i], projectId: widget.project.id),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => AppErrorWidget(message: e.toString(), onRetry: () => ref.read(tasksProvider(widget.project.id).notifier).fetchTasks()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => AddTaskBottomSheet(projectId: widget.project.id)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
