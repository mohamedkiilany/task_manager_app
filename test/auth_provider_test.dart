import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:task_manager_app/features/auth/domain/models/user_model.dart';
import 'package:task_manager_app/features/auth/domain/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  UserModel? _user;
  String? _token;

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<UserModel?> login(String email, String password) async {
    _user = UserModel(id: 1, name: 'Test', email: email);
    _token = 'fake|token';
    return _user;
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    _user = UserModel(id: 2, name: name, email: email);
    _token = 'fake|token';
    return _user!;
  }

  @override
  Future<void> logout() async {
    _user = null;
    _token = null;
  }
}

void main() {
  test('authProvider login updates state to data', () async {
    final fake = FakeAuthRepository();
    final container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(fake)]);

    final notifier = container.read(authProvider.notifier);

    await notifier.login('user@example.com', 'password');

    final state = container.read(authProvider);
    expect(state, isA<AsyncValue<UserModel?>>());
    expect(state.asData?.value?.email, 'user@example.com');

    await notifier.logout();
    final afterLogout = container.read(authProvider);
    expect(afterLogout.asData?.value, null);

    container.dispose();
  });
}
