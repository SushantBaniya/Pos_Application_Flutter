import 'package:dio/dio.dart';
import 'package:pos_app/core/network/api_constants.dart';
import 'package:pos_app/services/auth_interceptor.dart';
import 'package:pos_app/services/token_storage.dart';
import 'package:pos_app/services/error_interceptor.dart';

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
    dio.interceptors.addAll([
      AuthInterceptor(tokenStorage), // Add the AuthInterceptor to the Dio instance
      AppLogInterceptor() // Add the AppInterceptor to the Dio instance
    ]);
    return dio;
  }
}