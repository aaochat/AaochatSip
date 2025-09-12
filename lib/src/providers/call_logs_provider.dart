import 'package:callingproject/src/api_response/api_response.dart';
import 'package:callingproject/src/repository/auth_repository.dart';
import 'package:callingproject/src/utils/shared_prefs.dart';
import 'package:dio/dio.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/calls_model.dart';
import '../Repository/api_calling_repository.dart';
import '../event/place_call_event.dart';
import '../models/call_model.dart';

class CallProvider extends ChangeNotifier {
  final _phoneNumbCtrl = TextEditingController();

  TextEditingController get phoneNumbCtrl => _phoneNumbCtrl;
  String? _errText;
  String? _sip_username;
  String? _ExtentionNumber;
  EventTaxi eventBus = EventTaxiImpl.singleton();

  String? get errorText => _errText;

  String? get mSipUserNAme => _sip_username;

  String? get mExtentionNumber => _ExtentionNumber;

  deleteAccount(BuildContext context) async {
    for (int i = 0; i < context.read<AccountsModel>().length; i++) {
      await context.read<AccountsModel>().deleteAccount(i);
    }
  }

  void mInvite(BuildContext context, bool withVideo, AccountsModel accounts) {
    if (_phoneNumbCtrl.text.isEmpty) {
      _errText = "Phone number is empty";
      return;
    }

    final accounts = context.read<AccountsModel>();
    if (accounts.selAccountId == null) {
      _errText = "Account not selected";
      return;
    }

    //Prepare destination details
    CallDestination dest = CallDestination(
      _phoneNumbCtrl.text.toString(),
      accounts.selAccountId!,
      withVideo,
    );

    context
        .read<AppCallsModel>()
        .invite(dest)
        .then((_) => _errText = "")
        .catchError((error) {
          _errText = error.toString();
        });

    notifyListeners();
  }

  void clearText() {
    _phoneNumbCtrl.clear();
  }

  placeCall(String phoneNumber) {
    eventBus.fire(PlaceCallEvent(phoneNumber, placeCall: false));
  }

  bool _loading = false;
  late String _error;

  String get error => _error;

  bool get isLoading => _loading;

  Future<void> logout() async {
 await AuthRepository.logout();
    SharedPrefs().clear();
  }

  Future<bool> DeleteAccountApiCalling(BuildContext context) async {
    _loading = true;
    _error = "";
    notifyListeners();
    try {
      ApiResponse<String> response =
          await ApiCallingRepo.GetDeleteAccountRequest(context);
      if (response.status == "success") {
        return true;
      } else {
        return false;
      }
    } on DioException catch (dioError) {
      // Handle Dio-specific errors
      if (dioError.response!.statusCode == 400) {
        _error = dioError.response?.data["message"];
      } else if (dioError.type == DioExceptionType.receiveTimeout) {
        _error = "Receive timeout. Try again later.";
      } else if (dioError.type == DioExceptionType.badResponse) {
        _error = "Bad response: ${dioError.response?.statusCode}";
      } else if (dioError.type == DioExceptionType.connectionError) {
        _error = "Connection error. Please try again.";
      } else {
        _error = "Unexpected error occurred: ${dioError.message}";
      }
      return false;
    } catch (e) {
      // Handle any other unexpected errors
      _error = "An unexpected error occurred: $e";
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
