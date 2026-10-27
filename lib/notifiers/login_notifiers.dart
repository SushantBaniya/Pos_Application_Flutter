import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/Repository/auth_service.dart';


class LoginNotifier extends AsyncNotifier<bool> {
    @override
    Future<bool> build() async {
      // Initial state is false, indicating the user is not logged in.
      return false;
    }
  
    Future<void> login(String email, String password) async {
      // Simulate a login process with a delay.
      state = const AsyncValue.loading();
      await Future.delayed(const Duration(seconds: 2));
  
      // Here you would typically call your authentication service.
      // For demonstration, we assume the login is always successful.
      state = const AsyncValue.data(true);
    }
  
    Future<void> logout() async {
      // Simulate a logout process with a delay.
      state = const AsyncValue.loading();
      await Future.delayed(const Duration(seconds: 1));
  
      // Here you would typically call your authentication service to log out.
      state = const AsyncValue.data(false);
    }
}