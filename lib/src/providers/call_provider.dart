import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/calls_model.dart';

import '../Repository/api_calling_repository.dart';
import '../event/place_call_event.dart';
import '../models/call_model.dart';
import '../repository/auth_repository.dart';
import '../utils/shared_prefs.dart';

class CallProvider extends ChangeNotifier {
  final _phoneNumbCtrl = TextEditingController();
  final EventTaxi eventBus = EventTaxiImpl.singleton();

  TextEditingController get phoneNumbCtrl => _phoneNumbCtrl;
  String? _errText;
  bool _loading = false;

  String? get errorText => _errText;
  bool get isLoading => _loading;

  Future<void> deleteAccount(BuildContext context) async {
    final accounts = context.read<AccountsModel>();
    for (var i = 0; i < accounts.length; i++) {
      await accounts.deleteAccount(i);
    }
  }

  void mInvite(BuildContext context, bool withVideo) {
    if (_phoneNumbCtrl.text.isEmpty) {
      _errText = 'Phone number is empty';
      notifyListeners();
      return;
    }

    final accounts = context.read<AccountsModel>();
    if (accounts.selAccountId == null) {
      _errText = 'Account not selected';
      notifyListeners();
      return;
    }

    final dest = CallDestination(
      _phoneNumbCtrl.text,
      accounts.selAccountId!,
      withVideo,
    );

    context.read<AppCallsModel>().invite(dest).then((_) {
      _errText = '';
      notifyListeners();
    }).catchError((Object error) {
      _errText = error.toString();
      notifyListeners();
    });
  }

  void clearText() => _phoneNumbCtrl.clear();

  void placeCall(String phoneNumber) {
    eventBus.fire(PlaceCallEvent(phoneNumber, placeCall: false));
  }

  Future<String?> logout() async {
    try {
      final response = await AuthRepository.logout();
      if (response.status == 'success') {
        await SharedPrefs().clear();
        return null;
      }
      return response.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteAccountApi(BuildContext context) async {
    _loading = true;
    notifyListeners();
    try {
      final response = await ApiCallingRepo.GetDeleteAccountRequest(context);
      return response.status == 'success' ? null : response.message;
    } catch (e) {
      return e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
