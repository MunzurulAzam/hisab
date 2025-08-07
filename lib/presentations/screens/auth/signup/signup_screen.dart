import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisab/core/config/routes/app_routes.dart';
import 'package:hisab/core/utils/size_config.dart';
import 'package:hisab/logic/providers/auth/provider/auth_provider.dart';
import 'package:hisab/presentations/widgets/on_process_button_widget.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final notifier = ref.read(authProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(blurRadius: 20, color: Colors.black12, offset: Offset(0, 5))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Create Account', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                getVerticalSpace(8),
                Text('Register to get started', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                getVerticalSpace(32),

                /// Email Field
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                getVerticalSpace(16),

                /// Password Field
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                getVerticalSpace(16),

                /// Confirm Password Field
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                getVerticalSpace(24),

                /// Register Button
                SizedBox(
                  width: double.infinity,
                  height: getScreenHeight(48),
                  child: OnProcessButtonWidget(
                    onTap: authState.isLoading
                        ? null
                        : () async {
                            if (passwordController.text != confirmController.text) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(const SnackBar(content: Text("Passwords don't match"), backgroundColor: Colors.redAccent));
                              return null;
                            } else {
                              final success = await ref.read(authProvider.notifier).register(emailController.text.trim(), passwordController.text);
                              return success;
                            }
                          },
                    onDone: (isSuccess) {
                      if (isSuccess == true) {
                        notifier.clearState();
                        GoRouter.of(context).pushNamed(RouteName.loginScreen);
                      }
                    },
                    // style: ElevatedButton.styleFrom(
                    //   backgroundColor: Colors.deepPurple,
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    // ),
                    child: authState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Register',
                            style: TextStyle(fontSize: getFontSize(16), fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                /// Error message from backend
                if (authState.error != null)
                  Padding(
                    padding: EdgeInsets.only(top: getScreenHeight(12.0)),
                    child: Text(authState.error!, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
