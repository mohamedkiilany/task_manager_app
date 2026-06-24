// lib/shared/widgets/error_widget.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({Key? key, required this.message, this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            if (onRetry != null) ElevatedButton(onPressed: onRetry, child: const Text(AppStrings.retry))
          ],
        ),
      ),
    );
  }
}
