import 'dart:io';

import 'package:callingproject/src/utils/app_settings.dart';
import 'package:callingproject/src/utils/constants.dart';
import 'package:callingproject/src/utils/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';

import '../Providers/login_provider.dart';
import '../utils/shared_prefs.dart';

enum DioMethod { post, get, put, delete }

class ApiClient {
  ApiClient._singleton();

  static final ApiClient instance = ApiClient._singleton();

  Future<Response> request(
    BuildContext context,
    String endpoint,
    DioMethod method, {
    Map<String, dynamic>? param,
    formData,
  }) async {
    String? mToken = await SecureStorage().read(Constants.TOKEN);
    try {
      final dio = Dio(
          BaseOptions(
            baseUrl: AppSettings.BASED_URL,
            contentType: Headers.jsonContentType,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              HttpHeaders.authorizationHeader: 'Bearer $mToken',
              "Content-Type": "application/json",
            },
          ),
        )
        ..interceptors.addAll([
          AuthInterceptor(context),
          LogInterceptor(
            request: true,
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            responseHeader: false,
            error: true,
            logPrint: (obj) => print(obj),
          ),
        ]);
      switch (method) {
        case DioMethod.post:
          return dio.post(endpoint, data: param ?? formData);
        case DioMethod.get:
          return dio.get(endpoint, queryParameters: param);
        case DioMethod.put:
          return dio.put(endpoint, data: param ?? formData);
        case DioMethod.delete:
          return dio.delete(endpoint, data: param ?? formData);
        default:
          return dio.post(endpoint, data: param ?? formData);
      }
    } catch (e) {
      throw Exception('Network error');
    }
  }
}

class AuthInterceptor extends Interceptor {
  // Simulate token access; replace with secure storage
  final BuildContext context;

  AuthInterceptor(this.context);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    String? mToken = await SecureStorage().read(Constants.TOKEN);
    if (mToken != null) {
      options.headers["Authorization"] = "Bearer $mToken";
      options.contentType = Headers.formUrlEncodedContentType;
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // TODO: implement onResponse
    super.onResponse(response, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle token refresh, logging, or custom errors
    if (err.response?.statusCode == 401) {
      await SecureStorage().clear();
      SharedPrefs().clear();

      try {
        for (int i = 0; i < context.read<AccountsModel>().length; i++) {
          await context.read<AccountsModel>().deleteAccount(i);
        }
      } catch (e) {
        print(e);
      }

      /// Example: clear navigation and go to login
      Navigator.of(context).pushNamedAndRemoveUntil('/domain', (route) => false);

      /// Or show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Session expired, please login again.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } /*else if (err.response?.statusCode == 400) {
      Provider.of<LoginProvider>(context, listen: false).setError(err.response?.data["message"] ?? "Bad Request (400)");
    }*/
    super.onError(err, handler);
  }
}
