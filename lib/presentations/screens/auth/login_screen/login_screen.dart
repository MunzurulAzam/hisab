import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisab/core/config/routes/app_routes.dart';
import 'package:hisab/logic/providers/auth/provider/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: phoneNumberController,
              decoration: const InputDecoration(labelText: 'phone number'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: authState.isLoading == true ? null : () {
                ref.read(authProvider.notifier).login(
                  phoneNumberController.text.trim(),
                  passwordController.text,
                );
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () => GoRouter.of(context).go(RouteName.registerScreen),
              child: const Text('Create Account'),
            ),
            if (authState.error != null) Text(
              authState.error!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}