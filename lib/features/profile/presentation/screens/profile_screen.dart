// lib/features/profile/presentation/screens/profile_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/secure_storage.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<String?> _emailFromToken() async {
    final token = await SecureStorage.getToken();
    if (token == null) return null;
    try {
      final decoded = utf8.decode(base64Decode(token));
      final parts = decoded.split('|');
      if (parts.isNotEmpty) return parts[0];
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.asData?.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36)),
            const SizedBox(height: 16),
            FutureBuilder<String?>(
              future: _emailFromToken(),
              builder: (context, snap) {
                final emailFromToken = snap.data;
                final email = user?.email ?? emailFromToken ?? 'Unknown';
                final name = user?.name ?? '-';
                return Column(
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(email, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                );
              },
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
