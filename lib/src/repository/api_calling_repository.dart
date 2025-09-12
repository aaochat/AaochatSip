import 'package:callingproject/src/api_response/api_response.dart';
import 'package:callingproject/src/utils/shared_prefs.dart';
import 'package:flutter/cupertino.dart';

import '../network/api_client.dart';
import '../utils/constants.dart';

class ApiCallingRepo {

  static Future<ApiResponse<String>> GetDeleteAccountRequest(BuildContext context) async {
    String? IDS = SharedPrefs().getValue(Constants.USER_DOMAIN_ID);

    final response = await ApiClient.instance.request(
        '/tenant/$IDS/users/delete', DioMethod.get
    );

      ApiResponse<String> apiResponse = ApiResponse<String>.fromJsonString(
        response.data,
            (data) => data.toString(),
      );
      if (apiResponse.status == "success") {
        return apiResponse;
      } else {
        return ApiResponse<String>(
          status: 'error',
          message: apiResponse.message,
        );
      }
  }

  // static Future<ApiResponse<String>> GetLogOutRequest(BuildContext context) async {
  //   String? IDS = SharedPrefs().getValue(Constants.USER_DOMAIN_ID);
  //
  //   final response = await ApiClient.instance.request(
  //       '/tenant/$IDS/auth/logout', DioMethod.post
  //   );
  //
  //     ApiResponse<String> apiResponse = ApiResponse<String>.fromJsonString(
  //       response.data,
  //           (data) => data.toString(),
  //     );
  //
  //     if (apiResponse.status == "success") {
  //       return apiResponse;
  //     } else {
  //       return ApiResponse<String>(
  //         status: "error",
  //         message: apiResponse.message,
  //       );
  //     }
  // }


}
