import '../services/token_storage.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
    final TokenStorage storage;

    AuthInterceptor(this.storage); //Dependency injection of TokenStorage instance

    @override
    Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
        try
        {
            final accessToken = await storage.getAccessToken();
            if (accessToken != null) {
                options.headers['Authorization'] = 'Bearer $accessToken'; // Add the access token to the request headers
            }
            handler.next(options);// Continue with the request
         } 
         catch (error, stackTrace) {
            handler.reject(DioException(
                requestOptions: options,
                error: error,
                stackTrace: stackTrace,
                type: DioExceptionType.unknown,
                message: 'Error retrieving access token',
            ));
         }
         
    }
}