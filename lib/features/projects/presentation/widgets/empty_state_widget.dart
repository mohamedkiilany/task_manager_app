// lib/features/projects/presentation/widgets/empty_state_widget.dart

import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRefresh;

  const EmptyStateWidget({Key? key, this.message = 'No projects found', this.onRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.folder_open, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message, style: Theme.of(context).textTheme.titleMedium),
          if (onRefresh != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRefresh, child: const Text('Refresh'))
          ]
        ],
      ),
    );
  }
}
