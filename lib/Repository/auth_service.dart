import 'package:pos_app/services/token_storage.dart';
import 'package:pos_app/services/login_api.dart';

class AuthService {
  final TokenStorage tokenStorage;
  final LoginApi loginApi;

  AuthService({required this.tokenStorage, required this.loginApi});

  Future<LoginResponse> login(LoginRequest request) async{
    final response = await loginApi.login(request);

    await tokenStorage.saveTokens(accessToken: response.tokens.accessToken, refreshToken: response.tokens.refreshToken);
    return response;
  };

  
}