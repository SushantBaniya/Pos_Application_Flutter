import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/Repository/auth_service.dart';
import 'package:pos_app/models/login.dart';


class LoginNotifier extends AsyncNotifier<LoginResponse?> {
    @override
    Future<LoginResponse?> build() async {
      return null;
    }

    Future<void> login(String email, String password) async {
      state = const AsyncValue.loading();
      try {
        final request = LoginRequest(email: email, password: password);
        final response = await AuthService.login(request);
        state = AsyncValue.data(response);
      } on SocketException catch (e) {
        state = AsyncValue.error('No Internet connection: ${e.message}');
      } catch (e) {
        state = AsyncValue.error('Login failed: $e');
      }
    }
}