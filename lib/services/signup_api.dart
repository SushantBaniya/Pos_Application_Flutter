import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:pos_app/models/signup.dart';

part 'signup_api.g.dart';


@RestApi()
abstract class SignupApi {
  factory SignupApi(Dio dio, {String? baseUrl}) = _SignupApi;

  @POST('api/signup/')
  Future<SignupResponse> signup(@Body() SignupRequest request);
}