import 'dart:async';

import 'package:callingproject/src/pages/main_page.dart';
import 'package:callingproject/src/pages/domain_screen.dart';
import 'package:callingproject/src/providers/call_logs_provider.dart';
import 'package:callingproject/src/utils/Constants.dart';
import 'package:callingproject/src/utils/secure_storage.dart';
import 'package:callingproject/src/utils/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  static const routeName = "/splash";

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      bool? isLoggedIn = await SharedPrefs().getValue(Constants.IS_LOGGEDIN);
 
      var mProvider = context.read<CallProvider>();
      if (isLoggedIn==true) {
        // mProvider.deleteAccount(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Domainscreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.asset('assets/voip_logo.png',height: 150,width: 150,)));
  }
}
