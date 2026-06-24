// lib/features/auth/presentation/providers/auth_provider.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_model.dart';
import '../../domain/auth_repository.dart';
import '../../data/auth_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl());
final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<UserModel?> {
  late final AuthRepository _repo;

  @override
  Future<UserModel?> build() async {
    _repo = ref.read(authRepositoryProvider);
    final token = await _repo.getToken();
    if (token != null) {
      try {
        final decoded = utf8.decode(base64Decode(token));
        final parts = decoded.split('|');
        final email = parts.isNotEmpty ? parts[0] : '';
        final name = email.contains('@') ? email.split('@')[0] : email;
        return UserModel(id: 0, name: name, email: email);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.login(email, password);
      if (user == null) throw Exception('Invalid credentials');
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.register(name, email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncValue.data(null);
  }
}
