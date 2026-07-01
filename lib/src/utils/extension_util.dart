import 'dart:convert';

import 'package:aaochat_sip/src/models/extension_model.dart';
import 'package:aaochat_sip/src/utils/constants.dart';
import 'package:aaochat_sip/src/utils/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';

class ExtensionUtil {
  static Future<void> deleteAllAccounts(BuildContext context) async {
    for (int i = 0; i < context.read<AccountsModel>().length; i++) {
      await context.read<AccountsModel>().deleteAccount(i);
    }
  }

  static Future<void> initializeAccounts(BuildContext context) async {
    List<Extension> extensions =
        ((jsonDecode(
                  await SharedPrefs().getValue(Constants.EXTENSIONS) ?? '[]',
                ))
                as List)
            .map((e) => Extension.fromJson(e))
            .toList();

    for (int i = 0; i < extensions.length; i++) {
      await context.read<AccountsModel>().addAccount(
        extensions[i].toAccountModel(),
      );
    }
  }
}
