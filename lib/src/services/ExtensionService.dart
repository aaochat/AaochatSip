import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/network_model.dart';

import '../../main.dart';
import '../utils/Constants.dart';
import '../utils/shared_prefs.dart';

class ExtensionService {
  static Future<void> updateExtensionNo(BuildContext context) async {
    AccountModel account = AccountModel(
      sipServer: "192.168.75.240",
      sipExtension: SharedPrefs().getValue(Constants.EXTENSION_NUMBER),
      sipPassword: SharedPrefs().getValue(Constants.SIP_PASSWORD),
    );

    account.transport = SipTransport.udp;
    account.ringTonePath = MyApp.getRingtonePath();

    for (int i = 0; i < context.read<AccountsModel>().length; i++) {
      await context.read<AccountsModel>().deleteAccount(i);
    }

    await context.read<AccountsModel>().addAccount(account);
  }

  static bool isRegistered() {
    return SharedPrefs().getValue(Constants.IS_LOGGEDIN) == true;
  }
}
