
import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;      // safe to show the user
  final int? statusCode;
  final Object? original;    // the raw error, for logs only

  const AppException(this.message, {this.statusCode, this.original});

  @override
  String toString() => 'AppException($statusCode): $message';
}


AppException mapError(Object error) {
  if (error is AppException) return error;

  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException('The server took too long to respond.', original: error);
      case DioExceptionType.connectionError:
        return AppException('No internet connection.', original: error);
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        return AppException(_messageForStatus(code, error.response?.data),
            statusCode: code, original: error);
      case DioExceptionType.cancel:
        return AppException('Request cancelled.', original: error);
      default:
        return AppException('Something went wrong.', original: error);
    }
  }
  return AppException('Unexpected error.', original: error);
}

String _messageForStatus(int? code, dynamic data) {
  // Prefer the server's own message if it sends one
  if (data is Map && data['message'] is String) return data['message'];
  switch (code) {
    case 400: return 'Invalid request.';
    case 401: return 'Wrong email or password.';
    case 403: return 'You do not have permission.';
    case 404: return 'Not found.';
    case 422: return 'Please check the entered details.';
    case 500:
    case 502:
    case 503: return 'Server error. Try again later.';
    default:  return 'Request failed ($code).';
  }
}