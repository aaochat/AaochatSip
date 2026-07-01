import 'package:aaochat_sip/src/providers/domain_provider.dart';
import 'package:aaochat_sip/src/providers/theme_provider.dart';
import 'package:aaochat_sip/src/utils/app_branding.dart';
import 'package:aaochat_sip/src/widget/appbar.dart';
import 'package:aaochat_sip/src/widget/branded_logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/snackbar_util.dart';
import 'login_screen.dart';

class Domainscreen extends StatefulWidget {
  const Domainscreen({super.key});

  static const routeName = '/domain';

  @override
  State<Domainscreen> createState() => _DomainscreenState();
}

class _DomainscreenState extends State<Domainscreen> {
  final _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Colors.grey),
  );

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DomainProvider>(context);

    return Scaffold(
      appBar: const ThemeAppBar(),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          width: double.infinity,
          color: ThemeProvider.cardDark,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              children: [
                const BrandedLogo(height: 100),
                const SizedBox(height: 20),
                Text(
                  'Connect your organization',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter your ${AppBranding.brandName} domain to access ${AppBranding.appName}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: provider.domainController,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Organization domain',
                    hintText: 'your-company',
                    enabledBorder: _border,
                    focusedBorder: _border.copyWith(
                      borderSide: const BorderSide(color: ThemeProvider.accentTeal, width: 2),
                    ),
                  ),
                  onSubmitted: (_) => _onSubmit(provider),
                ),
                const SizedBox(height: 20),
                Consumer<DomainProvider>(
                  builder: (context, provider, _) {
                    return ElevatedButton(
                      onPressed: provider.isLoading ? null : () => _onSubmit(provider),
                      child: provider.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Continue'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit(DomainProvider provider) async {
    if (!provider.validate()) {
      showAppSnackBar(context, message: provider.ValidatorDomainMsg);
      return;
    }
    final error = await provider.validateDomain();
    if (!mounted) return;
    if (error == null) {
      provider.clearMyText();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      showAppSnackBar(context, message: error);
    }
  }
}
