import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';

import '../Providers/theme_provider.dart';
import '../event/place_call_event.dart';
import '../models/sip_user_model.dart';
import '../providers/layout_provider.dart';
import '../repository/sip_repository.dart';
import '../utils/Constants.dart';
import '../utils/shared_prefs.dart';
import 'branded_logo.dart';

/// Dashboard home tab — welcome, quick actions, recent calls, team preview.
class WorkspaceHomeTab extends StatefulWidget {
  const WorkspaceHomeTab({
    super.key,
    required this.onOpenDialer,
    required this.onOpenHistory,
    required this.onOpenVoicemail,
  });

  final VoidCallback onOpenDialer;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenVoicemail;

  @override
  State<WorkspaceHomeTab> createState() => _WorkspaceHomeTabState();
}

class _WorkspaceHomeTabState extends State<WorkspaceHomeTab> {
  List<SIPUser> _teamPreview = [];
  final _eventBus = EventTaxiImpl.singleton();

  @override
  void initState() {
    super.initState();
    _loadTeamPreview();
    _loadRecentCalls();
  }

  Future<void> _loadRecentCalls() async {
    try {
      final accountId = context.read<AccountsModel>().selAccountId;
      final account = context.read<AccountsModel>().accounts.firstWhere(
            (a) => a.myAccId == accountId,
          );
      final ext = await SharedPrefs().getValue(Constants.EXTENSION_NUMBER) ?? '';
      if (mounted) {
        await context.read<LayoutProvider>().getCallLogs(
              account.sipServer,
              ext,
              isFirstTime: true,
            );
      }
    } catch (_) {}
  }

  Future<void> _loadTeamPreview() async {
    try {
      final accountId = context.read<AccountsModel>().selAccountId;
      final account = context.read<AccountsModel>().accounts.firstWhere(
            (a) => a.myAccId == accountId,
          );
      final response = await SipRepository.getAllSipUsers(account.sipServer);
      if (mounted && response.status == 'success') {
        setState(() => _teamPreview = (response.data ?? []).take(6).toList());
      }
    } catch (_) {}
  }

  Future<String> _userGreeting() async {
    final email = await SharedPrefs().getValue(Constants.EMAILID) ?? '';
    if (email.contains('@')) {
      final name = email.split('@').first.replaceAll('.', ' ');
      return name.isNotEmpty
          ? name[0].toUpperCase() + name.substring(1)
          : 'there';
    }
    return 'there';
  }

  @override
  Widget build(BuildContext context) {
    final layout = context.watch<LayoutProvider>();
    final recent = layout.logList.take(3).toList();
    final vmCount = layout.voiceMailList.length;

    return RefreshIndicator(
      onRefresh: () async {
        final accountId = context.read<AccountsModel>().selAccountId;
        final account = context.read<AccountsModel>().accounts.firstWhere(
              (a) => a.myAccId == accountId,
            );
        final ext = await SharedPrefs().getValue(Constants.EXTENSION_NUMBER) ?? '';
        await layout.refreshLogs(account.sipServer, ext);
        await _loadTeamPreview();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const BrandedLogo(height: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<String>(
                    future: _userGreeting(),
                    builder: (context, snap) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${snap.data ?? '…'}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Text(
                          'Your organization workspace',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _QuickActions(
              onDial: widget.onOpenDialer,
              onHistory: widget.onOpenHistory,
              onVoicemail: widget.onOpenVoicemail,
              voicemailCount: vmCount,
            ),
            const SizedBox(height: 24),
            Text('Recent calls', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (recent.isEmpty)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.history, color: Colors.white54),
                  title: Text('No recent calls'),
                  subtitle: Text('Your call history will appear here'),
                ),
              )
            else
              ...recent.map((log) => _RecentCallTile(log: log, eventBus: _eventBus)),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('Team online', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (_teamPreview.isNotEmpty)
                  Text('${_teamPreview.length}+ members', style: const TextStyle(color: Colors.white54)),
              ],
            ),
            const SizedBox(height: 8),
            if (_teamPreview.isEmpty)
              const Text('Loading team…', style: TextStyle(color: Colors.white54))
            else
              SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _teamPreview.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final u = _teamPreview[i];
                    return InkWell(
                      onTap: () => _eventBus.fire(
                        PlaceCallEvent(u.extension, placeCall: true),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: ThemeProvider.primaryTeal.withValues(alpha: 0.3),
                            child: Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : '?'),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 56,
                            child: Text(
                              u.name.split(' ').first,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onDial,
    required this.onHistory,
    required this.onVoicemail,
    required this.voicemailCount,
  });

  final VoidCallback onDial;
  final VoidCallback onHistory;
  final VoidCallback onVoicemail;
  final int voicemailCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.dialpad,
            label: 'Quick Dial',
            color: ThemeProvider.primaryTeal,
            onTap: onDial,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.history,
            label: 'History',
            color: ThemeProvider.cardDark,
            onTap: onHistory,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.voicemail,
            label: 'Voicemail',
            color: ThemeProvider.cardDark,
            onTap: onVoicemail,
            badge: voicemailCount > 0 ? '$voicemailCount' : null,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 28, color: Colors.white),
                  if (badge != null)
                    Positioned(
                      top: -4,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(badge!, style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentCallTile extends StatelessWidget {
  const _RecentCallTile({required this.log, required this.eventBus});

  final CallLogResponse log;
  final EventTaxi eventBus;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Icon(
          log.src.length <= 4 ? Icons.call_made : Icons.call_received,
          color: ThemeProvider.accentTeal,
        ),
        title: Text(log.dstCnam.isNotEmpty ? log.dstCnam : log.dst),
        subtitle: Text(log.getFormattedCallDate()),
        trailing: IconButton(
          icon: const Icon(Icons.call),
          onPressed: () {
            final number = log.dst ?? '';
            if (number.isNotEmpty) {
              eventBus.fire(PlaceCallEvent(number, placeCall: true));
            }
          },
        ),
      ),
    );
  }
}
