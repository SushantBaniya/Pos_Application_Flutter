import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/models/login.dart';
import 'package:pos_app/notifiers/providers.dart';
import 'package:pos_app/models/signup.dart';

class LoginNotifier extends AsyncNotifier<LoginResponse?> {
    @override
    Future<LoginResponse?> build() async {
      return null;
    }

    Future<void> login(String email, String password) async {
      state = const AsyncValue.loading();
      try {
        final request = LoginRequest(email: email, password: password); // request contains the object of LoginRequest class which is created by passing the email and password to its constructor. The LoginRequest class is a model class that represents the request body for the login API call.
        final authService = ref.read(authServiceProvider);
        final response = await authService.login(request); // object of authservice is used to call the login method in which the object of loginrequest is passed to it and the response is stored in the response variable. The login method in the AuthService class calls the login method in the LoginApi class, which makes the actual API call to the backend server and returns a LoginResponse object.
        state = AsyncValue.data(response); // the state is updated to AsyncValue.data(response) which means that the login was successful and the response is stored in the state. The state is of type AsyncValue<LoginResponse?> which means that it can be either loading, data or error. The data state contains the response object of type LoginResponse which is a model class that represents the response body for the login API call.
      } on SocketException catch (e) {
        state = AsyncValue.error('No Internet connection: ${e.message}', StackTrace.current);
      } catch (e) {
        state = AsyncValue.error('Login failed: ${e.toString()}', StackTrace.current);
      }
    }
}

final loginNotifierProvider = AsyncNotifierProvider<LoginNotifier, LoginResponse?>(
  () => LoginNotifier(),
);

class SignupNotifier extends AsyncNotifier<SignupResponse?> {
  @override
  Future<SignupResponse?> build() async {
    return null;
  }

  Future<void> signup(String username, String email, String password, String phone, String businessName) async {
    state = const AsyncValue.loading();
    try {
      final request = SignupRequest(username: username, email: email, password: password, phone_number: phone, business_name: businessName);
      final authService = ref.read(authServiceProvider);
      final response = await authService.signup(request);
      state = AsyncValue.data(response);
    } on SocketException catch (e) {
      state = AsyncValue.error('No Internet connection: ${e.message}', StackTrace.current);
    } catch (e) {
      state = AsyncValue.error('Signup failed: ${e.toString()}', StackTrace.current);
    }
  }
}

final signupNotifierProvider = AsyncNotifierProvider<SignupNotifier, SignupResponse?>(
  () => SignupNotifier(),
);