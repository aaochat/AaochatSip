import 'package:callingproject/src/api_response/api_response.dart';
import 'package:callingproject/src/api_response/call_log_response.dart';
import 'package:callingproject/src/network/api_client.dart';
import 'package:callingproject/src/utils/Constants.dart';
import 'package:callingproject/src/utils/shared_prefs.dart';
import 'package:dio/dio.dart';

class SipRepository {
  static Future<ApiResponse<List<CallLogResponse>>> getCallLogs(
    String mExtensionId,
    Map<String, dynamic> data,
  ) async {
    try {
      String? tenantId = SharedPrefs().getValue(Constants.USER_DOMAIN_ID);

      final response = await ApiClient.instance.request(
        '/tenant/$tenantId/sip-servers/$mExtensionId/logs', DioMethod.get, param: data,
      );
      ApiResponse<List<CallLogResponse>> apiResponse =
          ApiResponse<List<CallLogResponse>>.fromMap(
            response.data
          );

      if(apiResponse.status == 'success') {
        apiResponse.data = (response.data['data'] as List).map((e) => CallLogResponse.fromJson(e)).toList();
        return apiResponse;
      }

      return apiResponse;
    } on DioException catch (dioError) {
      print(dioError);
      return ApiResponse<List<CallLogResponse>>(
        status: 'error',
        message: dioError.response?.data["message"],
      );
    } catch (e) {
      print(e);
      return ApiResponse<List<CallLogResponse>>(
        status: 'error',
        message: 'Failed to process your request. Please try again.',
      );
    }
  }

  static Future<ApiResponse<String>> validateDomain(String domainName) async {
    try {
      final response = await ApiClient.instance.request(
        '/master/auth/domain',
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
}
