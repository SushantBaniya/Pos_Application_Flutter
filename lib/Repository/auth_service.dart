import 'package:pos_app/services/token_storage.dart';
import 'package:pos_app/services/login_api.dart';
import 'package:pos_app/models/login.dart';
import 'package:pos_app/core/error/exceptions.dart';

class AuthService {
  final TokenStorage tokenStorage;
  final LoginApi loginApi;

  AuthService({required this.tokenStorage, required this.loginApi});

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await loginApi.login(request);
      await tokenStorage.saveTokens(
        accessToken: response.tokens.accessToken,
        refreshToken: response.tokens.refreshToken,
      );
      return response;
    } catch (e) {
      throw mapError(e);
    }
  }
}
