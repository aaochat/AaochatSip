import 'dart:async';

import 'package:callingproject/src/pages/dashboard_page.dart';
import 'package:callingproject/src/pages/domain_page.dart';
import 'package:callingproject/src/utils/Constants.dart';
import 'package:callingproject/src/utils/shared_prefs.dart';
import 'package:flutter/material.dart';

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
      if (isLoggedIn==true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DomainScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Image.asset('assets/voip_logo.png',height: 150,width: 150,)));
  }
}
