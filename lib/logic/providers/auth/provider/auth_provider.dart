import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisab/core/db/hive/user_model/user_model.dart';
import 'package:hisab/logic/providers/auth/state/auth_state.dart';
import 'package:hive/hive.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<bool> register(String phoneNumber, String password) async {
    try {
      // Start loading
      state = state.copyWith(isLoading: true, error: null);

      final usersBox = Hive.box<User>('users');

      // Check if phone number already exists
      if (usersBox.values.any((user) => user.phoneNumber == phoneNumber)) {
        state = state.copyWith(isLoading: false, error: 'Phone number already registered');
        return false;
      }

      // Create and save new user
      final newUser = User(phoneNumber: phoneNumber, password: password);
      await usersBox.add(newUser);

      // Update state with new user
      state = state.copyWith(user: newUser, isLoading: false, error: null);

      log('User registered successfully: ${newUser.phoneNumber}');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Registration failed: ${e.toString()}');
      log('Registration error: ${e.toString()}');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final usersBox = Hive.box<User>('users');
      final user = usersBox.values.firstWhere(
        (u) => u.phoneNumber == email && u.password == password,
        orElse: () => User(phoneNumber: '', password: ''),
      );

      if (user.phoneNumber.isNotEmpty) {
        state = state.copyWith(user: user, isLoading: false);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Invalid credentials');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Login failed');
      return false;
    }
  }

  void logout() {
    Hive.box<User>('users').clear();
  }

  void clearState() {
    state = AuthState();
  }
}
