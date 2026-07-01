import 'dart:async';

import 'package:aaochat_sip/src/pages/domain_screen.dart';
import 'package:aaochat_sip/src/pages/main_page.dart';
import 'package:aaochat_sip/src/pages/onboarding_flow.dart';
import 'package:aaochat_sip/src/utils/app_branding.dart';
import 'package:aaochat_sip/src/utils/app_settings.dart';
import 'package:aaochat_sip/src/utils/constants.dart';
import 'package:aaochat_sip/src/utils/layout_util.dart';
import 'package:aaochat_sip/src/utils/shared_prefs.dart';
import 'package:aaochat_sip/src/widget/branded_logo.dart';
import 'package:aaochat_sip/src/providers/theme_provider.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  static const routeName = '/splash';

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _navigateNext);
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;
    final isLoggedIn = await SharedPrefs().getValue<bool>(Constants.IS_LOGGEDIN);
    if (!mounted) return;

    if (isLoggedIn == true) {
      if (LayoutUtil.isMobile()) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
        return;
      }
      final onboardingDone =
          await SharedPrefs().getValue<bool>(AppSettings.onboardingCompleteKey);
      if (onboardingDone != true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingFlow()),
        );
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Domainscreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeProvider.surfaceDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BrandedLogo(height: 120),
            const SizedBox(height: 24),
            Text(
              AppBranding.appName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              AppBranding.appTagline,
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
