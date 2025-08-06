import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisab/core/db/hive/user_model/user_model.dart';
import 'package:hisab/logic/providers/auth/state/auth_state.dart';
import 'package:hive/hive.dart';
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

Future<void> register(String phoneNumber, String password) async {
  try {
    // Start loading
    state = state.copyWith(isLoading: true, error: null);
    
    final usersBox = Hive.box<User>('users');
    
    // Check if phone number exists
    if (usersBox.values.any((user) => user.phoneNumber == phoneNumber)) {
      state = state.copyWith(
        isLoading: false,
        error: 'Phone number already registered'
      );
      return;
    }

    // Create and save new user
    final newUser = User(phoneNumber: phoneNumber, password: password);
    await usersBox.add(newUser);
    
    // Update state with new user
    state = state.copyWith(
      user: newUser,
      isLoading: false,
      error: null,
    );
    
    log('User registered successfully: ${newUser.phoneNumber}');
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      error: 'Registration failed: ${e.toString()}',
    );
    log('Registration error: ${e.toString()}');
  }
}

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true);
      
      final usersBox = Hive.box<User>('users');
      final user = usersBox.values.firstWhere(
        (u) => u.phoneNumber == email && u.password == password,
        orElse: () => User(phoneNumber: '', password: ''),
      );

      if (user.phoneNumber.isNotEmpty) {
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(error: 'Invalid credentials');
      }
    } catch (e) {
      state = state.copyWith(error: 'Login failed');
    }
  }

  void logout() {
    Hive.box<User>('users').clear();
  }
}