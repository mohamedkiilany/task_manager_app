// lib/features/auth/data/auth_repository_impl.dart

import 'dart:convert';

import '../domain/auth_repository.dart';
import '../domain/models/user_model.dart';
import 'auth_remote_datasource.dart';
import '../../../core/utils/secure_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote = AuthRemoteDataSource();

  @override
  Future<UserModel?> login(String email, String password) async {
    final user = await _remote.login(email, password);
    if (user != null) {
      // generate a fake token
      final token = _generateFakeToken(user.email);
      await SecureStorage.saveToken(token);
    }
    return user;
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    final user = await _remote.register(name, email, password);
    final token = _generateFakeToken(user.email);
    await SecureStorage.saveToken(token);
    return user;
  }

  @override
  Future<void> logout() async {
    await SecureStorage.deleteToken();
  }

  @override
  Future<String?> getToken() async => await SecureStorage.getToken();

  String _generateFakeToken(String email) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final raw = '$email|$ts';
    return base64Encode(raw.codeUnits);
  }
}

