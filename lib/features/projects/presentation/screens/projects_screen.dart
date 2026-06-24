// lib/features/projects/presentation/screens/projects_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/projects_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/empty_state_widget.dart';
import 'package:task_manager_app/shared/widgets/loading_widget.dart';
import 'package:task_manager_app/shared/widgets/error_widget.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectsProvider.notifier).fetchProjects();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(projectsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: state.when(
        data: (projects) {
          if (projects.isEmpty) return EmptyStateWidget(onRefresh: _onRefresh);
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: projects.length,
              itemBuilder: (context, i) => ProjectCard(project: projects[i]),
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => AppErrorWidget(message: e.toString(), onRetry: _onRefresh),
      ),
    );
  }
}
