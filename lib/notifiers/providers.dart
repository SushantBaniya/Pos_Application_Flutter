import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/services/token_storage.dart';
import 'package:pos_app/services/login_api.dart';
import 'package:pos_app/Repository/auth_service.dart';
;

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});


final authServiceProvider = Provider<AuthService>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthService(tokenStorage: tokenStorage, loginApi: LoginApi());
});