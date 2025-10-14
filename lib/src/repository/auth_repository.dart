import 'package:callingproject/src/api_response/api_response.dart';
import 'package:callingproject/src/api_response/login_response.dart';
import 'package:callingproject/src/network/api_client.dart';
import 'package:callingproject/src/utils/Constants.dart';
import 'package:callingproject/src/utils/app_settings.dart';
import 'package:callingproject/src/utils/shared_prefs.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  static Future<ApiResponse<LoginResponse>> login(
    String email,
    String password,
  ) async {
    try {
      String? IDS = SharedPrefs().getValue(Constants.USER_DOMAIN_ID);

      final response = await ApiClient.instance.request(
        AppSettings.API_URL + '/tenant/$IDS/auth/login',
        DioMethod.post,
        param: {'email': email, 'password': password},
      );
      ApiResponse<LoginResponse> apiResponse =
          ApiResponse<LoginResponse>.fromJson(
            response.data,
            (data) => LoginResponse.fromJson(data),
          );

      return apiResponse;
    } on DioException catch (dioError) {
      print(dioError);
      return ApiResponse<LoginResponse>(
        status: 'error',
        message: dioError.response?.data["message"],
      );
    } catch (e) {
      print(e);
      return ApiResponse<LoginResponse>(
        status: 'error',
        message: 'Failed to process your request. Please try again.',
      );
    }
  }

  static Future<ApiResponse<String>> Signup(String fName,
      String LName,
      String email,
      String password,) async {
    try {
      final response = await ApiClient.instance.request(
        "https://beta-aaochat-sip-api.aaochat.com/master/auth/signup",
        DioMethod.post,
        param: {'fname': fName, 'lname': LName, 'email': email, 'password': password},
      );
      ApiResponse<String> apiResponse =
      ApiResponse<String>.fromJsonString(
        response.data,
            (data) => data.toString(),
      );

      return apiResponse;
    } on DioException catch (dioError) {
      print(dioError);
      return ApiResponse<String>(
        status: 'error',
        message: dioError.response?.data["message"],
      );
    } catch (e) {
      print(e);
      return ApiResponse<String>(
        status: 'error',
        message: 'Failed to process your request. Please try again.',
      );
    }
  }

  static Future<ApiResponse<String>> validateDomain(String domainName) async {
    try {
      final response = await ApiClient.instance.request(
       AppSettings.API_URL + '/master/auth/domain',
        DioMethod.post,
        param: {'domain': domainName},
      );
      ApiResponse<String> apiResponse = ApiResponse<String>.fromMap(
        response.data
      );

      if(apiResponse.status == 'success') {
        apiResponse.data = response.data['data'];
        return apiResponse;
      }

      return apiResponse;
    } on DioException catch (dioError) {
      print(dioError);
      return ApiResponse<String>(
        status: 'error',
        message: dioError.response?.data["message"],
      );
    } catch (e) {
      print(e);
      return ApiResponse<String>(
        status: 'error',
        message: 'Failed to process your request. Please try again.',
      );
    }
  }

  // logout
  static Future<ApiResponse<String>> logout() async {
    try {
       String? tenantId = SharedPrefs().getValue(Constants.USER_DOMAIN_ID);
      final response = await ApiClient.instance.request(
          AppSettings.API_URL +'/tenant/$tenantId/auth/logout', DioMethod.post
      );
      ApiResponse<String> apiResponse = ApiResponse<String>.fromJsonString(
        response.data,
            (data) => data.toString(),
      );

      return apiResponse;

    } on DioException catch (dioError) {
      print(dioError);
      return ApiResponse<String>(
        status: 'error',
        message: dioError.response?.data["message"],
      );
    } catch (e) {
      print(e);
      return ApiResponse<String>(
        status: 'error',
        message: 'Failed to process your request. Please try again.',
      );
    }
  }
}
