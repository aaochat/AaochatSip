import 'package:callingproject/src/api_response/api_response.dart';
import 'package:callingproject/src/repository/auth_repository.dart';
import 'package:callingproject/src/utils/Constants.dart';
import 'package:callingproject/src/utils/shared_prefs.dart';
import 'package:flutter/cupertino.dart';

class DomainProvider extends ChangeNotifier {
  bool _loading = false;
  late String _error;

  String get error => _error;

  bool get isLoading => _loading;

  var ValidatorDomainMsg;
  final domainController = TextEditingController();

  bool validate() {
    bool isValid = true;

    if (domainController.text.trim().isEmpty) {
      ValidatorDomainMsg = 'Domain is required';
      isValid = false;
    } else {
      ValidatorDomainMsg = null;
    }

    notifyListeners();
    return isValid;
  }

  Future<String?> validateDomain() async {
    _loading = true;
    _error = "";
    notifyListeners();
    try {
      ApiResponse<String> response = await AuthRepository.validateDomain(
        domainController.text.toString(),
      );
      if (response.status == "success") {
        SharedPrefs().setValue(Constants.USER_DOMAIN_ID, response.data!);
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

  void clearMyText() {
    domainController.clear();
    notifyListeners();
  }
}
