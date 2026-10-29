import 'package:pos_app/services/token_storage.dart';
import 'package:pos_app/services/retrofit_all.dart';
import 'package:pos_app/models/login.dart';
import 'package:pos_app/core/error/exceptions.dart';
import 'package:pos_app/models/signup.dart';

class AuthService {
  final TokenStorage tokenStorage;
  final AuthApi loginApi;
  final AuthApi signupApi;

  AuthService({required this.tokenStorage, required this.loginApi, required this.signupApi});

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await loginApi.login(request);
      await tokenStorage.saveTokens(
        accessToken: response.tokens.access,
        refreshToken: response.tokens.refresh,
      );
      return response;
    } catch (e) {
      throw mapError(e);
    }
  }

  Future<SignupResponse> signup(SignupRequest request) async {
    try {
      final response = await signupApi.signup(request);
      return response;
    } catch (e) {
      throw mapError(e);
    }
  }
}
