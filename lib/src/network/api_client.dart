import 'package:aaochat_sip/src/utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../utils/shared_prefs.dart';

enum DioMethod { post, get, put, delete }

class ApiClient {
  ApiClient._singleton();

  static final ApiClient instance = ApiClient._singleton();

  Future<Response> request(
    String endpoint,
    DioMethod method, {
    Map<String, dynamic>? param,
    formData,
  }) async {
    final interceptors = <Interceptor>[AuthInterceptor()];
    if (kDebugMode) {
      interceptors.add(
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }

    final dio = Dio(
      BaseOptions(
        contentType: Headers.jsonContentType,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          "Content-Type": "application/json",
        },
      ),
    )..interceptors.addAll(interceptors);
    switch (method) {
      case DioMethod.post:
        return dio.post(endpoint, data: param ?? formData);
      case DioMethod.get:
        return dio.get(endpoint, queryParameters: param);
      case DioMethod.put:
        return dio.put(endpoint, data: param ?? formData);
      case DioMethod.delete:
        return dio.delete(endpoint, data: param ?? formData);
    }
  }
}

class AuthInterceptor extends Interceptor {
  AuthInterceptor();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    String? mToken = await SharedPrefs().getValue(Constants.TOKEN);
    if (mToken != null) {
      options.headers["Authorization"] = "Bearer $mToken";
      options.contentType = Headers.formUrlEncodedContentType;
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle token refresh, logging, or custom errors
    if (err.response?.statusCode == 401) {
      SharedPrefs().clear();
      // redirect to login page
    }
    super.onError(err, handler);
  }
}
