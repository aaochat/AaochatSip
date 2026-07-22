import 'dart:io';
import 'package:callingproject/src/utils/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Providers/theme_provider.dart';
import '../utils/app_branding.dart';
import '../utils/shared_prefs.dart';
import '../widget/branded_logo.dart';
import 'main_page.dart';

/// First-run onboarding: welcome → value props → permissions → extension ready.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  static const routeName = '/onboarding';

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _pageController = PageController();
  int _page = 0;
  bool _micGranted = false;

  Future<void> _completeOnboarding() async {
    await SharedPrefs().setValue(AppSettings.onboardingCompleteKey, true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
    );
  }

  Future<void> _requestMic() async {
    final status = await Permission.microphone.request();
    setState(() => _micGranted = status.isGranted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const BrandedLogo(height: 36),
                  const SizedBox(width: 12),
                  Text(
                    AppBranding.appName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Text('${_page + 1} / 3'),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: (_page + 1) / 3,
              backgroundColor: Colors.grey.shade800,
              color: ThemeProvider.accentTeal,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _WelcomePage(onNext: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      )),
                  _ValuePropsPage(onNext: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      )),
                  _PermissionsPage(
                    micGranted: _micGranted,
                    onRequestMic: _requestMic,
                    onFinish: _completeOnboarding,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const BrandedLogo(height: 120),
          const SizedBox(height: 32),
          Text(
            'Welcome to ${AppBranding.appName}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            AppBranding.appTagline,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: const Text('Get Started'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValuePropsPage extends StatelessWidget {
  const _ValuePropsPage({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Built for your organization',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          _valueCard(Icons.groups, 'Team Directory', 'Find and call colleagues by name or extension.'),
          _valueCard(Icons.shield_outlined, 'Secure Calling', 'Enterprise-grade VoIP on your AaoChat tenant.'),
          _valueCard(Icons.insights, 'Call Insights', 'Review summaries and recordings from your workspace.'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _valueCard(IconData icon, String title, String body) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: ThemeProvider.accentTeal, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(body),
      ),
    );
  }
}

class _PermissionsPage extends StatelessWidget {
  const _PermissionsPage({
    required this.micGranted,
    required this.onRequestMic,
    required this.onFinish,
  });

  final bool micGranted;
  final VoidCallback onRequestMic;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            micGranted ? Icons.check_circle : Icons.mic,
            size: 64,
            color: micGranted ? Colors.green : ThemeProvider.accentTeal,
          ),
          const SizedBox(height: 24),
          Text(
            'Microphone access',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          const Text(
            'Aao VOIP needs microphone access to place and receive calls. '
            'On iOS, notifications help you answer incoming calls promptly.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 32),
          if (!micGranted)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRequestMic,
                child: const Text('Allow Microphone'),
              ),
            ),
          if (Platform.isIOS && !micGranted) ...[
            const SizedBox(height: 12),
            const Text(
              'You can enable notifications in Settings after setup.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: micGranted ? onFinish : onRequestMic,
              child: Text(micGranted ? 'Enter Workspace' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
