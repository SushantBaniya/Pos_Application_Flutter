import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:pos_app/models/login.dart';

part 'login_api.g.dart';

@RestApi()
abstract class LoginApi {
  factory LoginApi(Dio dio, {String? baseUrl}) = _LoginApi;

  @POST('/api/login')
  Future<LoginResponse> login(@Body() LoginRequest request); // Add the @Body() annotation to indicate that the request body should be sent as JSON and the response should be deserialized into a LoginResponse object
}
