// lib/features/tasks/presentation/widgets/add_task_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tasks_provider.dart';

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  final int projectId;
  const AddTaskBottomSheet({Key? key, required this.projectId}) : super(key: key);

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    setState(() => _loading = true);
    await ref.read(tasksProvider(widget.projectId).notifier).addTask(title);
    setState(() => _loading = false);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _controller, decoration: const InputDecoration(labelText: 'Task title')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loading ? null : _submit, child: _loading ? const CircularProgressIndicator() : const Text('Add Task'))
        ],
      ),
    );
  }
}
