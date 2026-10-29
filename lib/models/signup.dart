class SignupRequest {
  String? username;
  String? email;
  String? password;
  String? phone_number;
  String? business_name;

  SignupRequest({this.username, this.email, this.password, this.phone_number, this.business_name});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'phone_number': phone_number,
      'business_name': business_name,
    };
  }
}

class SignupResponse {
  final String message;

  SignupResponse({required this.message});

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      message: json['message'] as String,
    );
  }
}