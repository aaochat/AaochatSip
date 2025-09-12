import 'dart:convert';

import 'package:callingproject/src/api_response/api_response.dart';
import 'package:callingproject/src/repository/auth_repository.dart';
import 'package:callingproject/src/utils/Constants.dart';
import 'package:callingproject/src/utils/shared_prefs.dart';
import 'package:flutter/cupertino.dart';

import '../api_response/login_response.dart';

class LoginProvider with ChangeNotifier {
  bool _loading = false;
  late String _error;

  String get error => _error;

  void setError(String message) {
    _error = message;
    notifyListeners();
  }

  bool get isLoading => _loading;

  String? ErrorMessage;
  TextEditingController mEmailController = TextEditingController();
  TextEditingController mPasswordController = TextEditingController();

  Future<String?> login(String email, String password) async {
    _loading = true;
    _error = "";
    notifyListeners();
    try {
      ApiResponse<LoginResponse> response = await AuthRepository.login(
        email,
        password,
      );
      if (response.status == "success") {
        if (response.data?.user.extensions?.isEmpty ?? true) {
          return 'Failed to login. No extensions assigned to your account. Please contact your administrator.';
        }

        await SharedPrefs().setValue(
          Constants.USER,
          jsonEncode(response.data?.user.toJson()),
        );
        await SharedPrefs().setValue(
          Constants.TOKEN,
          response.data?.token ?? '',
        );

        await SharedPrefs().setValue(
          Constants.IS_LOGGEDIN,
          true,
        );
        await SharedPrefs().setValue(
          Constants.EXTENSIONS,
          jsonEncode(response.data?.user.extensions?.map((e) => e.toJson()).toList()),
        );

  

        return null;
      } else {
        return response.message;
      }
    } catch (e) {
      _error = "An unexpected error occurred: $e";
      return _error;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  String? validate() {

    if (mEmailController.text.trim().isEmpty) {
      return ErrorMessage = 'Email/Username is required';
    } else if (!mEmailController.text.trim().contains('@')) {
      return ErrorMessage = 'Please enter a valid email';
    } else if (mPasswordController.text.trim().isEmpty) {
      return ErrorMessage = 'Password is required';
    } 

    notifyListeners();
    return null;
  }

}
