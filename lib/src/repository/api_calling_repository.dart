import 'package:callingproject/src/api_response/api_response.dart';
import 'package:callingproject/src/utils/shared_prefs.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../network/api_client.dart';
import '../utils/app_settings.dart';
import '../utils/constants.dart';

class ApiCallingRepo {

  static Future<ApiResponse<String>> GetDeleteAccountRequest(BuildContext context) async {
    try {
      String? IDS = SharedPrefs().getValue(Constants.USER_DOMAIN_ID);

      final response = await ApiClient.instance.request(
        AppSettings.API_URL + '/tenant/$IDS/users/delete',
        DioMethod.get,
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
