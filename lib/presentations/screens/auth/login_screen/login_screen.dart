import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisab/core/config/routes/app_routes.dart';
import 'package:hisab/core/utils/size_config.dart';
import 'package:hisab/logic/providers/auth/provider/auth_provider.dart';
import 'package:hisab/presentations/widgets/on_process_button_widget.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding:  EdgeInsets.symmetric(horizontal: getScreenWidth(24.0)),
          child: Container(
            padding:  EdgeInsets.all(getScreenWidth(24.0)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(blurRadius: getBorderRadius(20), color: Colors.black12, offset: const Offset(0, 5))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Welcome Back 👋', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                getVerticalSpace(8),
                Text('Please login to your account', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                getVerticalSpace(32),

                /// Phone Number Field
                TextField(
                  controller: phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(getBorderRadius(12))),
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
                getVerticalSpace(24),

                /// Login Button
                SizedBox(
                  width: double.infinity,
                  height: getScreenHeight(48),
                  child: OnProcessButtonWidget(
                    onTap: authState.isLoading
                        ? null
                        : () async {
                            final success = await ref.read(authProvider.notifier).login(phoneNumberController.text.trim(), passwordController.text);
                            return success;
                          },
                          onDone: (isSuccess) {
                            if (isSuccess == true) {
                              GoRouter.of(context).go(RouteName.home);
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
                        : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                getVerticalSpace(12),

                /// Error message
                if (authState.error != null)
                  Padding(
                    padding: EdgeInsets.only(top: getScreenHeight(8.0)),
                    child: Text(authState.error!, style: const TextStyle(color: Colors.red)),
                  ),

                /// Create Account
                TextButton(
                  onPressed: () => GoRouter.of(context).go(RouteName.registerScreen),
                  child: const Text('Don\'t have an account? Create one', style: TextStyle(color: Colors.deepPurple)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
