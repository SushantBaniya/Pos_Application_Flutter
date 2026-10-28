import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pos_app/services/token_storage.dart';
import 'package:pos_app/services/login_api.dart';
import 'package:pos_app/Repository/auth_service.dart';
import 'package:pos_app/core/network/dio_client.dart';

// Providers return objects that can be used throughout the app. They are used to manage state and dependencies in a clean and efficient way.
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final dioClientProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider); // we can use read too because we are not listening to changes in tokenStorage, but watch is more appropriate here because if the tokenStorage changes, we want to recreate the Dio instance with the new tokenStorage.
  return DioClient.create(tokenStorage); //returns an object of DioClient class which is created by calling the static method create and passing the tokenStorage object to it. The create method returns a Dio instance that is configured with the base URL, timeouts, headers, and an AuthInterceptor that uses the tokenStorage to add the access token to the request headers.
});

final loginApiProvider = Provider<LoginApi>((ref) {
  final dio = ref.watch(dioClientProvider);
  return LoginApi(dio);
});


final authServiceProvider = Provider<AuthService>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final loginApi = ref.watch(loginApiProvider);
  return AuthService(tokenStorage: tokenStorage, loginApi: loginApi); // return an object of AuthService class which is created by passing the tokenStorage and loginApi objects to its constructor. The AuthService class provides methods for logging in and managing tokens, and it uses the TokenStorage and LoginApi instances to perform these tasks.
});