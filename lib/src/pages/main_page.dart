import 'dart:io';

import 'package:aaochat_sip/src/event/place_call_event.dart';
import 'package:aaochat_sip/src/event/refresh_call_log_event.dart';
import 'package:aaochat_sip/src/event/refresh_voice_mail_event.dart';
import 'package:aaochat_sip/src/models/call_model.dart';
import 'package:aaochat_sip/src/pages/directory_page.dart';
import 'package:aaochat_sip/src/pages/mobile_call_page.dart';
import 'package:aaochat_sip/src/pages/settings_page.dart';
import 'package:aaochat_sip/src/providers/layout_provider.dart';
import 'package:aaochat_sip/src/providers/theme_provider.dart';
import 'package:aaochat_sip/src/utils/app_branding.dart';
import 'package:aaochat_sip/src/utils/layout_util.dart';
import 'package:aaochat_sip/src/widget/active_call_controls.dart';
import 'package:aaochat_sip/src/widget/dialpad_widget.dart';
import 'package:aaochat_sip/src/widget/branded_logo.dart';
import 'package:aaochat_sip/src/widget/desktop_top_bar.dart';
import 'package:aaochat_sip/src/widget/desktop_workspace_dashboard.dart';
import 'package:aaochat_sip/src/widget/loglist_widget.dart';
import 'package:aaochat_sip/src/widget/voicemail_widget.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/network_model.dart';
import 'package:window_manager/window_manager.dart';

/// Routes to desktop workspace hub or classic mobile shell by platform.
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  static const routeName = '/workspace';

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _eventBus = EventTaxiImpl.singleton();

  @override
  void initState() {
    super.initState();
    _initCallsAndSocket();
    _eventBus.registerTo<PlaceCallEvent>(false).listen((_) {
      if (mounted) setState(() {});
    });
  }

  void _initCallsAndSocket() {
    final accounts = context.read<AccountsModel>();
    if (accounts.accounts.isNotEmpty) {
      final selected = accounts.accounts.firstWhere(
        (a) => a.myAccId == accounts.selAccountId,
        orElse: () => accounts.accounts.first,
      );
      context.read<LayoutProvider>().connectToSocket(selected.sipServer);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (LayoutUtil.isMobile()) {
      return const _MobileMainShell();
    }
    return const _DesktopMainShell();
  }
}

/// Desktop (Win/macOS/Linux): navigation rail + multi-panel workspace.
class _DesktopMainShell extends StatefulWidget {
  const _DesktopMainShell();

  @override
  State<_DesktopMainShell> createState() => _DesktopMainShellState();
}

class _DesktopMainShellState extends State<_DesktopMainShell> {
  var _sectionIndex = 0;
  final _eventBus = EventTaxiImpl.singleton();

  static const _sections = [
    (icon: Icons.dashboard_outlined, selected: Icons.dashboard, label: 'Dashboard'),
    (icon: Icons.contacts_outlined, selected: Icons.contacts, label: 'Directory'),
    (icon: Icons.history, selected: Icons.history, label: 'Call History'),
    (icon: Icons.voicemail_outlined, selected: Icons.voicemail, label: 'Voicemail'),
    (icon: Icons.settings_outlined, selected: Icons.settings, label: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    context.read<AppCallsModel>().onNewIncomingCall = () {
      if (Platform.isWindows) {
        WindowManager.instance.setAlwaysOnTop(true);
        WindowManager.instance.focus();
        Future.delayed(const Duration(seconds: 2), () {
          WindowManager.instance.setAlwaysOnTop(false);
        });
      } else if (Platform.isMacOS) {
        _bringWindowToFront();
      }
      if (mounted) setState(() => _sectionIndex = 0);
    };
    _eventBus.registerTo<PlaceCallEvent>(false).listen((_) {
      if (mounted) setState(() => _sectionIndex = 0);
    });
  }

  Future<void> _bringWindowToFront() async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setAlwaysOnTop(true);
    await Future.delayed(const Duration(milliseconds: 100));
    await windowManager.setAlwaysOnTop(false);
  }

  void _openDialer() {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: ThemeProvider.cardDark,
        insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 640),
          child: const DialpadWidget(false),
        ),
      ),
    );
  }

  void _onSectionSelected(int index) {
    setState(() => _sectionIndex = index);
    final layout = context.read<LayoutProvider>();
    if (index == 2) layout.goToCallLogs();
    if (index == 3) layout.getVoiceMailList(context);
  }

  String get _sectionTitle => _sections[_sectionIndex].label;

  @override
  Widget build(BuildContext context) {
    final calls = context.watch<AppCallsModel>();

    if (calls.isNotEmpty) {
      return Scaffold(
        backgroundColor: ThemeProvider.surfaceDark,
        body: Column(
          children: [
            DesktopTopBar(
              sectionTitle: 'Active call',
              subtitle: 'Manage your current session',
              actions: [
                FilledButton.icon(
                  onPressed: _openDialer,
                  icon: const Icon(Icons.add_call, size: 18),
                  label: const Text('Add call'),
                ),
              ],
            ),
            const Expanded(child: CallSessionPage()),
            if (_networkBanner(context) != null) _networkBanner(context)!,
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: ThemeProvider.surfaceDark,
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.sizeOf(context).width >= 1100,
            minExtendedWidth: 180,
            backgroundColor: ThemeProvider.cardDark,
            selectedIndex: _sectionIndex,
            onDestinationSelected: _onSectionSelected,
            labelType: MediaQuery.sizeOf(context).width >= 1100
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Platform.isWindows
                  ? null
                  : Column(
                      children: [
                        const BrandedLogo(height: 36),
                        const SizedBox(height: 8),
                        Text(
                          AppBranding.appName,
                          style: const TextStyle(fontSize: 11, color: Colors.white54),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
            destinations: [
              for (final s in _sections)
                NavigationRailDestination(
                  icon: Icon(s.icon),
                  selectedIcon: Icon(s.selected, color: ThemeProvider.accentTeal),
                  label: Text(s.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: Column(
              children: [
                DesktopTopBar(
                  sectionTitle: _sectionTitle,
                  subtitle: AppBranding.appTagline,
                  actions: _buildToolbarActions(),
                ),
                Expanded(child: _buildSectionContent()),
                if (_networkBanner(context) != null) _networkBanner(context)!,
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildToolbarActions() {
    return [
      if (_sectionIndex == 0)
        FilledButton.icon(
          onPressed: _openDialer,
          icon: const Icon(Icons.dialpad, size: 18),
          label: const Text('Place call'),
        ),
      if (_sectionIndex == 2)
        IconButton(
          tooltip: 'Refresh history',
          onPressed: () => _eventBus.fire(RefreshCallLogEvent(isUpdate: true)),
          icon: const Icon(Icons.refresh),
        ),
      if (_sectionIndex == 3)
        IconButton(
          tooltip: 'Refresh voicemail',
          onPressed: () => _eventBus.fire(RefreshVoiceMailEvent()),
          icon: const Icon(Icons.refresh),
        ),
      const SizedBox(width: 8),
    ];
  }

  Widget _buildSectionContent() {
    switch (_sectionIndex) {
      case 0:
        return DesktopWorkspaceDashboard(
          onOpenDialer: _openDialer,
          onOpenHistory: () => _onSectionSelected(2),
          onOpenVoicemail: () => _onSectionSelected(3),
          onOpenDirectory: () => _onSectionSelected(1),
        );
      case 1:
        return const DirectoryPage();
      case 2:
        return const Padding(
          padding: EdgeInsets.all(16),
          child: LogListScreen(),
        );
      case 3:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: VoicemailWidget(),
        );
      case 4:
        return const SettingsPage(embedded: true);
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Mobile (iOS/Android): classic Phone / Call Logs / Voice Mails tabs.
class _MobileMainShell extends StatefulWidget {
  const _MobileMainShell();

  @override
  State<_MobileMainShell> createState() => _MobileMainShellState();
}

class _MobileMainShellState extends State<_MobileMainShell> {
  var _selectedPageIndex = 0;
  final _eventBus = EventTaxiImpl.singleton();

  @override
  void initState() {
    super.initState();
    context.read<AppCallsModel>().onNewIncomingCall = () {
      if (mounted) setState(() => _selectedPageIndex = 0);
    };
    _eventBus.registerTo<PlaceCallEvent>(false).listen((_) {
      if (mounted) setState(() => _selectedPageIndex = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppBranding.appName),
      ),
      body: IndexedStack(
        index: _selectedPageIndex,
        children: [
          const MobileCallPage(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Call Logs',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Expanded(child: LogListScreen()),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Voice Mails',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Expanded(child: VoicemailWidget()),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: (index) {
          setState(() => _selectedPageIndex = index);
          final layout = context.read<LayoutProvider>();
          if (index == 0) {
            layout.goToCallLogs();
          } else if (index == 2) {
            layout.getVoiceMailList(context);
          }
        },
        selectedItemColor: ThemeProvider.accentTeal,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dialpad_outlined),
            label: 'Phone',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Call Logs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.voice_chat),
            label: 'Voice Mails',
          ),
        ],
      ),
      bottomSheet: _networkBanner(context),
    );
  }
}

Widget? _networkBanner(BuildContext context) {
  if (context.watch<NetworkModel>().networkLost) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.red.shade800,
      child: const Text(
        'Internet connection lost',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
  return null;
}
