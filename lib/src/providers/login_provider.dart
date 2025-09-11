import 'package:callingproject/src/Repository/api_calling_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../api_response/based_response.dart';
import '../api_response/login_response.dart';
import '../utils/secure_storage.dart';

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

  Future<bool> ApiCalling(BuildContext context, String email, String password) async {
    _loading = true;
    _error = "";
    notifyListeners();
    try {
      BasedResponse<LoginResponse> response =
      await ApiCallingRepo.GetMakeApiRequest(context, email, password);
      if (response.status == "success") {
        await SecureStorage().write(
          key: 'username',
          value: mEmailController.text.toString(),
        );
        await SecureStorage().write(
          key: 'password',
          value: mPasswordController.text.toString(),
        );
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

  bool validate() {
    bool isValid = true;

    if (mEmailController.text.trim().isEmpty) {
      ErrorMessage = 'Email/Username is required';
      isValid = false;
    } else if (!mEmailController.text.trim().contains('@')) {
      ErrorMessage = 'Please enter a valid email';
      isValid = false;
    } else if (mPasswordController.text.trim().isEmpty) {
      ErrorMessage = 'Password is required';
      isValid = false;
    } else {
      ErrorMessage = null;
    }

    notifyListeners();
    return isValid;
  }

  Future<void> loadUsername() async {
    mEmailController = TextEditingController(text: "username");
    mPasswordController = TextEditingController(text: "password");
    notifyListeners();
  }

  void clearMyText() {
    mEmailController.clear();
    mPasswordController.clear();
    notifyListeners();
  }

}
