import 'package:flutter/cupertino.dart';

import '../api_response/api_response.dart';
import '../repository/auth_repository.dart';

class SignupProvider extends ChangeNotifier {
  bool _loading = false;
  late String _error;

  String get error => _error;

  void setError(String message) {
    _error = message;
    notifyListeners();
  }

  bool get isLoading => _loading;

  String? ErrorMessage;
  TextEditingController mFNameController = TextEditingController();
  TextEditingController mLNameController = TextEditingController();
  TextEditingController mEmailController = TextEditingController();
  TextEditingController mPasswordController = TextEditingController();

  Future<bool> Signup(String fName, String LName, String email, String password) async {
    _loading = true;
    _error = "";
    notifyListeners();
    try {
      ApiResponse<String> response = await AuthRepository.Signup(fName, LName, email, password);
      if (response.status == "success") {
        mFNameController.clear();
        mLNameController.clear();
        mEmailController.clear();
        mPasswordController.clear();
        _error = response.message!;
        return true;
      } else {
        _error = response.message!;
        return false;
      }
    } catch (e) {
      _error = "An unexpected error occurred: $e";
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void dispose() {
    mFNameController.dispose();
    mLNameController.dispose();
    mEmailController.dispose();
    mPasswordController.dispose();
    super.dispose();
  }

  String? validate() {
    if (mFNameController.text.trim().isEmpty) {
      return ErrorMessage = 'First Name is required';
    } else if (mLNameController.text.trim().isEmpty) {
      return ErrorMessage = 'Last Name is required';
    } else if (mEmailController.text.trim().isEmpty) {
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
