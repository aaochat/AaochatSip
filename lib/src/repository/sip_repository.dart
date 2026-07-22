import 'package:callingproject/src/api_response/api_response.dart';
import 'package:callingproject/src/api_response/call_log_response.dart';
import 'package:callingproject/src/models/sip_user_model.dart';
import 'package:callingproject/src/models/voice_mail_log.dart';
import 'package:callingproject/src/network/api_client.dart';
import 'package:callingproject/src/utils/app_settings.dart';
import 'package:dio/dio.dart';

class SipRepository {
  static Future<ApiResponse<List<CallLogResponse>>> getCallLogs(
    String sipServerHost,
    String sipExtension,
    Map<String, dynamic> data,
  ) async {
    try {

      final response = await ApiClient.instance.request(
        "http://${sipServerHost.split(":")[0]}:${AppSettings.sipHttpApiPort}/logs/$sipExtension",
        DioMethod.get, param: data,
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
      return ApiResponse<List<CallLogResponse>>(
        status: 'error',
        message: dioError.response?.data["message"],
      );
    } catch (e) {
      return ApiResponse<List<CallLogResponse>>(
        status: 'error',
        message: 'Failed to process your request. Please try again.',
      );
    }
  }

  static Future<ApiResponse<List<VoiceMailLog>>> getVoiceMailList(String sipServerHost, String sipExtension) async {
    try {
      final response = await ApiClient.instance.request(
        'http://${sipServerHost.split(":")[0]}:${AppSettings.sipHttpApiPort}/voice-mails/$sipExtension',
        DioMethod.get,
      );
      ApiResponse<List<VoiceMailLog>> apiResponse = ApiResponse<List<VoiceMailLog>>.fromMap(
        response.data
      );
  
      if(apiResponse.status == 'success') {
        apiResponse.data = (response.data['data'] as List).map((e) => VoiceMailLog.fromMap(e)).toList();
        return apiResponse;
      }
  
      return apiResponse;
    } on DioException catch (dioError) {
      return ApiResponse<List<VoiceMailLog>>(
        status: 'error',
        message: dioError.response?.data["message"],
      );
    } catch (e) {
      return ApiResponse<List<VoiceMailLog>>(
        status: 'error',
        message: 'Failed to process your request. Please try again.',
      );
    }
  }


  static Future<ApiResponse<List<SIPUser>>> getAllSipUsers(String sipServerHost) async {
    try {
      final response = await ApiClient.instance.request(
        'http://${sipServerHost.split(":")[0]}:${AppSettings.sipHttpApiPort}/extensions',
        DioMethod.get,
      );
      ApiResponse<List<SIPUser>> apiResponse = ApiResponse<List<SIPUser>>.fromMap(
        response.data
      );
  
      if(apiResponse.status == 'success') {
        apiResponse.data = (response.data['data'] as List).map((e) => SIPUser.fromJson(e)).toList();
        return apiResponse;
      }
  
      return apiResponse;
    } on DioException catch (dioError) {
      return ApiResponse<List<SIPUser>>(
        status: 'error',
        message: dioError.response?.data["message"],
      );
    } catch (e) {
      return ApiResponse<List<SIPUser>>(
        status: 'error',
        message: 'Failed to process your request. Please try again.',
      );
    }
  }
}
