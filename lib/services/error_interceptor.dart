import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as dev;

class AppLogInterceptor extends Interceptor {
  static const _sensitive = {'password', 'accessToken', 'refreshToken', 'token'};

  dynamic _redact(dynamic data) {
    if (data is Map) {
      return data.map((k, v) =>
          MapEntry(k, _sensitive.contains(k) ? '***' : _redact(v)));
    }
    return data;
  }

  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler h) {
    if (kDebugMode) dev.log('➡️ ${o.method} ${o.uri}\nbody: ${_redact(o.data)}', name: 'HTTP');
    h.next(o);
  }

  @override
  void onResponse(Response r, ResponseInterceptorHandler h) {
    if (kDebugMode) dev.log('✅ ${r.statusCode} ${r.requestOptions.uri}', name: 'HTTP');
    h.next(r);
  }

  @override
  void onError(DioException e, ErrorInterceptorHandler h) {
    dev.log(
      '❌ ${e.type.name} ${e.response?.statusCode} ${e.requestOptions.method} ${e.requestOptions.uri}\n'
      'response: ${_redact(e.response?.data)}\n'
      'location: ${e.response?.headers.value('location')}',
      name: 'HTTP',
      error: e.message,
    );
    h.next(e);
  }
}