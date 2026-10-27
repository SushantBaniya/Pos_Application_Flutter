import 'package:pos_app/services/token_storage.dart';
import 'package:pos_app/services/login_api.dart';
import 'package:pos_app/models/login.dart';

class AuthService {
  final TokenStorage tokenStorage;
  final LoginApi loginApi;

  AuthService({required this.tokenStorage, required this.loginApi});

  Future<LoginResponse> login(LoginRequest request) async{ // this needs to be static to be accessed bt  other files because static wont need an object creation to be accessed and it doesnt help because we need to access the tokenStorage and loginApi which are not static so we will remove the static keyword
    final response = await loginApi.login(request);

    await tokenStorage.saveTokens(accessToken: response.tokens.accessToken, refreshToken: response.tokens.refreshToken);
    return response;
  }
}