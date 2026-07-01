import 'package:aaochat_sip/src/pages/main_page.dart';
import 'package:aaochat_sip/src/pages/onboarding_flow.dart';
import 'package:aaochat_sip/src/providers/login_provider.dart';
import 'package:aaochat_sip/src/providers/theme_provider.dart';
import 'package:aaochat_sip/src/utils/extension_util.dart';
import 'package:aaochat_sip/src/utils/layout_util.dart';
import 'package:aaochat_sip/src/widget/appbar.dart';
import 'package:aaochat_sip/src/widget/branded_logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/snackbar_util.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<LoginScreen> {
  final _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Colors.grey),
  );

  bool _obscureText = true;

  @override
  void initState() {
    ExtensionUtil.deleteAllAccounts(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mLoginProvider = Provider.of<LoginProvider>(context);

    return Scaffold(
      appBar: const ThemeAppBar(),
      body: Center(
        child: Container(
          width: double.infinity,
          color: ThemeProvider.cardDark,
          constraints: const BoxConstraints(maxWidth: 500),
          child: Center(child: _buildForm(context, mLoginProvider)),
        ),
      ),
    );
  }

  Future<void> _onSubmit(LoginProvider provider) async {
    if (provider.validate() != null) {
      showAppSnackBar(context, message: provider.validate() ?? '');
      return;
    }
    final error = await provider.login(
      provider.mEmailController.text.trim(),
      provider.mPasswordController.text,
    );
    if (!mounted) return;
    if (error == null) {
      await ExtensionUtil.initializeAccounts(context);
      if (!mounted) return;
      final nextPage = LayoutUtil.isMobile()
          ? const MainPage()
          : const OnboardingFlow();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => nextPage),
        (_) => false,
      );
    } else {
      showAppSnackBar(context, message: error);
    }
  }

  Widget _buildForm(BuildContext context, LoginProvider mLoginProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          const BrandedLogo(height: 88),
          const SizedBox(height: 16),
          Text(
            'Sign in to your workspace',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Use your AaoChat organization credentials to connect calling.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: mLoginProvider.mEmailController,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Work email',
              enabledBorder: _border,
              focusedBorder: _border.copyWith(
                borderSide: const BorderSide(color: ThemeProvider.accentTeal, width: 2),
              ),
            ),
            onSubmitted: (_) => _onSubmit(mLoginProvider),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: mLoginProvider.mPasswordController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              labelText: 'Password',
              enabledBorder: _border,
              focusedBorder: _border.copyWith(
                borderSide: const BorderSide(color: ThemeProvider.accentTeal, width: 2),
              ),
              suffixIcon: IconButton(
                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ),
            ),
            onSubmitted: (_) => _onSubmit(mLoginProvider),
          ),
          const SizedBox(height: 24),
          Consumer<LoginProvider>(
            builder: (context, provider, _) {
              return ElevatedButton(
                onPressed: provider.isLoading ? null : () => _onSubmit(provider),
                child: provider.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Sign In'),
              );
            },
          ),
        ],
      ),
    );
  }
}
