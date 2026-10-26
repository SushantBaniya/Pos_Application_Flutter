import 'package:dio/dio.dart';
import 'package:pos_app/core/network/api_constants.dart';
import 'package:pos_app/services/auth_interceptor.dart';
import 'package:pos_app/services/token_storage.dart';
import 'package:retrofit/retrofit.dart';

class DioClient {
  static Dio create(TokenStorage tokenStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    dio.interceptors.add(
      AuthInterceptor(tokenStorage) // Add the AuthInterceptor to the Dio instance
    );
    return dio;
  }
}