class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class LoginResponse {
  final String message;
  final Tokens tokens;
  final int business_id;

  LoginResponse({required this.message, required this.tokens, required this.business_id});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] as String,
      tokens: Tokens.fromJson(json['tokens'] as Map<String, dynamic>),
      business_id: json['business_id'] as int,
    );
  }
}

class Tokens {
  final String access;
  final String refresh;

  Tokens({required this.access, required this.refresh});

  factory Tokens.fromJson(Map<String, dynamic> json) {
    return Tokens(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
    );
  }
}