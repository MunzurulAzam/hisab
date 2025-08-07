import 'package:hisab/core/db/hive/user_model/user_model.dart';

class AuthState {
  final User? user;
  final bool isLoading;
   String? error;

   AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}