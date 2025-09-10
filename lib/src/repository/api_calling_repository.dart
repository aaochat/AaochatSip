import 'package:callingproject/src/utils/shared_prefs.dart';
import 'package:flutter/cupertino.dart';

import '../api_response/based_response.dart';
import '../api_response/call_log_response.dart';
import '../api_response/login_response.dart';
import '../network/api_client.dart';
import '../utils/app_settings.dart';
import '../utils/constants.dart';
import '../utils/secure_storage.dart';

class ApiCallingRepo {

  static Future<BasedResponse<String>> GetDeleteAccountRequest(BuildContext context) async {
    String? IDS = SharedPrefs().getValue(Constants.USER_DOMAIN_ID);

    final response = await ApiClient.instance.request(context,
        '/tenant/$IDS/users/delete', DioMethod.get
    );

    if (response.statusCode == 200) {
      BasedResponse<String> apiResponse = BasedResponse<String>.fromJsonString(
        response.data,
            (data) => data.toString(),
      );
      if (apiResponse.status == "success") {
        await SecureStorage().clear();
        await SharedPrefs().clear();

        return apiResponse;
      } else {
        return BasedResponse<String>(
          status: 'error',
          message: apiResponse.message,
        );
      }
    } else {
      return BasedResponse<String>(
        status: 'error',
        message: 'Something went wrong',
      );
    }
  }

  static Future<BasedResponse<String>> GetLogOutRequest(BuildContext context) async {
    String? IDS = SharedPrefs().getValue(Constants.USER_DOMAIN_ID);

    final response = await ApiClient.instance.request(context,
        '/tenant/$IDS/auth/logout', DioMethod.post
    );

    if (response.statusCode == 200) {
      BasedResponse<String> apiResponse = BasedResponse<String>.fromJsonString(
        response.data,
            (data) => data.toString(),
      );

      if (apiResponse.status == "success") {
        await SecureStorage().clear();
        await SharedPrefs().clear();
        return apiResponse;
      } else {
        return BasedResponse<String>(
          status: "error",
          message: apiResponse.message,
        );
      }
    } else {
      return BasedResponse<String>(
        status: 'error',
        message: 'Something went wrong',
      );
    }
  }

  static Future<BasedResponse<List<CallLogResponse>>> GetLogListRequest(BuildContext context,
      data) async {
    String? IDS = SharedPrefs().getValue(Constants.USER_DOMAIN_ID);
    String? mExtensionId = SharedPrefs().getValue(Constants.EXTENSION_NUMBER);

    final response = await ApiClient.instance.request(
      context,
      '/tenant/$IDS/sip-servers/$mExtensionId/logs', DioMethod.get, param: data,
    );

    if (response.statusCode == 200) {
      final data = response.data;

      final List<dynamic> list =
      (data is Map && data.containsKey("data")) ? data["data"] : data;

      final logs = list.map((e) => CallLogResponse.fromJson(e)).toList();

      BasedResponse<List<CallLogResponse>> apiResponse =
      BasedResponse<List<CallLogResponse>>.fromMap(data);

      if (apiResponse.status == 'success') {
        apiResponse.data = (response.data['data'] as List)
            .map((item) => CallLogResponse.fromJson(item))
            .toList();

        return apiResponse;
      } else {
        return BasedResponse<List<CallLogResponse>>(
          status: "error",
          message: apiResponse.message,
        );
      }
    } else {
      return BasedResponse<List<CallLogResponse>>(
        status: 'error',
        message: 'Something went wrong',
      );
    }
  }

  static Future<BasedResponse<LoginResponse>> GetMakeApiRequest(BuildContext context,
    String email,
    String password,
  ) async {
    String? IDS = SharedPrefs().getValue(Constants.USER_DOMAIN_ID);

    final response = await ApiClient.instance.request(
      context,
      '/tenant/$IDS/auth/login',
      DioMethod.post,
      param: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      BasedResponse<LoginResponse> apiResponse =
          BasedResponse<LoginResponse>.fromJson(
            response.data,
            (data) => LoginResponse.fromJson(data),
          );

      if (apiResponse.status == "success") {
        print('API call successful: ${response.data}');
        print("Token:::${apiResponse.data?.token}");

        await SecureStorage().write(
          key: Constants.TOKEN,
          value: apiResponse.data!.token,
        );

        await SecureStorage().write(
          key: Constants.ID,
          value: apiResponse.data!.user.id!,
        );

        await SecureStorage().write(
          key: Constants.EMAILID,
          value: apiResponse.data!.user.email!,
        );

        await SecureStorage().write(
          key: Constants.PHONE,
          value: apiResponse.data!.user.phoneNumber!,
        );

        await SecureStorage().write(
          key: Constants.ROLE,
          value: apiResponse.data!.user.role!,
        );

        await SecureStorage().write(
          key: Constants.STATUS,
          value: apiResponse.data!.user.status!,
        );

        await SecureStorage().write(
          key: Constants.SIP_SERVER_ID,
          value: apiResponse.data!.user.extensions![0].sipServer!.id!,
        );

        await SecureStorage().write(
          key: Constants.EXTENSION_NUMBER,
          value: apiResponse.data!.user.extensions![0].extensionNumber,
        );

        await SecureStorage().write(
          key: Constants.SIP_USERNAME,
          value: apiResponse.data!.user.extensions![0].sipUsername,
        );

        await SecureStorage().write(
          key: Constants.SIP_PASSWORD,
          value: apiResponse.data!.user.extensions![0].sipPassword,
        );


        await SharedPrefs().setValue(
            Constants.SIP_SERVER_NAME, apiResponse.data!.user.extensions![0].sipServer!.name
        );

        await SharedPrefs().setValue(
            Constants.SIP_SERVER_HOST, apiResponse.data!.user.extensions![0].sipServer!.host
        );

        await SharedPrefs().setValue(
            Constants.SIP_SERVER_PORT, apiResponse.data!.user.extensions![0].sipServer!.port
        );

        await SharedPrefs().setValue(
            Constants.SIP_SERVER_PROTOCOL, apiResponse.data!.user.extensions![0].sipServer!.protocol
        );

        await SharedPrefs().setValue(
            Constants.SIP_USERNAME, apiResponse.data!.user.extensions![0].sipUsername
        );

        await SharedPrefs().setValue(
            Constants.EXTENSION_NUMBER, apiResponse.data!.user.extensions![0].extensionNumber
        );

        await SharedPrefs().setValue(
            Constants.SIP_PASSWORD, apiResponse.data!.user.extensions![0].sipPassword
        );

        return apiResponse;
      } else {
        print('API call failed: ${apiResponse.message}');
        return BasedResponse<LoginResponse>(
          status: 'error',
          message: apiResponse.message,
        );
      }
    } else {
      print('API call failed: ${response.statusMessage}');
      return BasedResponse<LoginResponse>(
        status: 'error',
        message: 'Something went wrong',
      );
    }
  }

  static Future<BasedResponse<String>> GetDomainApiRequest(BuildContext context,
    String mDomainName,
  ) async {
    final response = await ApiClient.instance.request(
      context,
      AppSettings.API_DOMAIN,
      DioMethod.post,
      param: {'domain': mDomainName},
    );

    if (response.statusCode == 200) {
      BasedResponse<String> apiResponse = BasedResponse<String>.fromJsonString(
        response.data,
        (data) => data.toString(),
      );

      if (apiResponse.status == "success") {
        await SecureStorage().write(
          key: Constants.USER_DOMAIN_ID,
          value: apiResponse.data!,
        );

        await SharedPrefs().setValue(
          Constants.USER_DOMAIN_ID,
          apiResponse.data!,
        );

        return apiResponse;
      } else {
        print('API call failed: ${apiResponse.message}');
        return BasedResponse<String>(
          status: 'error',
          message: apiResponse.message,
        );
      }
    } else {
      print('API call failed: ${response.statusMessage}');
      return BasedResponse<String>(
        status: 'error',
        message: 'Something went wrong',
      );
    }
  }
}
