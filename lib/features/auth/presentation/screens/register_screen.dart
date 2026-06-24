// lib/features/auth/presentation/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).register(_name.text.trim(), _email.text.trim(), _password.text);
    final state = ref.read(authProvider);
    state.when(
      data: (user) {
        if (user != null) context.go('/home');
      },
      loading: () {},
      error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AuthTextField(controller: _name, label: 'Name', validator: (v) => (v != null && v.isNotEmpty) ? null : 'Enter name'),
              const SizedBox(height: 12),
              AuthTextField(controller: _email, label: 'Email', validator: (v) => v != null && v.contains('@') ? null : 'Enter valid email'),
              const SizedBox(height: 12),
              AuthTextField(controller: _password, label: 'Password', obscureText: true, validator: (v) => (v != null && v.length >= 4) ? null : 'Password too short'),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: isLoading ? null : _onRegister, child: isLoading ? const CircularProgressIndicator() : const Text('Register')),
            ],
          ),
        ),
      ),
    );
  }
}
