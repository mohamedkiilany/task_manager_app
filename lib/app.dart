// lib/app.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/utils/secure_storage.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/projects/presentation/screens/projects_screen.dart';
import 'features/tasks/presentation/screens/project_details_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/projects/domain/models/project_model.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator())),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const ProjectsScreen(),
    ),
    GoRoute(
      path: '/home/project/:id',
      name: 'details',
      builder: (context, state) {
        final idStr = (state.pathParameters.isNotEmpty && state.pathParameters.containsKey('id')) ? (state.pathParameters['id'] ?? '0') : (state.uri.pathSegments.isNotEmpty ? state.uri.pathSegments.last : '0');
        final id = int.tryParse(idStr) ?? 0;
        final project = ProjectModel(id: id, title: 'Project $id', description: '', status: (id % 2 == 1) ? 'Active' : 'Completed');
        return ProjectDetailsScreen(project: project);
      },

    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
  redirect: (context, state) async {
    // Async redirect to check token presence
    final token = await SecureStorage.getToken();
    final isLoggedIn = token != null;
    final loc = state.uri.toString();
    final isOnAuth = loc.startsWith('/login') || loc.startsWith('/register');

    if (!isLoggedIn && !isOnAuth) return '/login';
    if (isLoggedIn && isOnAuth) return '/home';
    return null;
  },
);
