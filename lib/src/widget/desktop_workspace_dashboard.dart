import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';

import '../Providers/theme_provider.dart';
import '../api_response/call_log_response.dart';
import '../models/sip_user_model.dart';
import '../providers/layout_provider.dart';
import '../repository/sip_repository.dart';
import '../utils/Constants.dart';
import '../utils/shared_prefs.dart';

/// Desktop dashboard — multi-panel layout with stats, recent calls table, team grid.
class DesktopWorkspaceDashboard extends StatefulWidget {
  const DesktopWorkspaceDashboard({
    super.key,
    required this.onOpenDialer,
    required this.onOpenHistory,
    required this.onOpenVoicemail,
    required this.onOpenDirectory,
  });

  final VoidCallback onOpenDialer;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenVoicemail;
  final VoidCallback onOpenDirectory;

  @override
  State<DesktopWorkspaceDashboard> createState() => _DesktopWorkspaceDashboardState();
}

class _DesktopWorkspaceDashboardState extends State<DesktopWorkspaceDashboard> {
  List<SIPUser> _teamMembers = [];
  final _eventBus = EventTaxiImpl.singleton();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadRecentCalls();
    await _loadTeam();
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

  Future<void> _loadTeam() async {
    try {
      final accountId = context.read<AccountsModel>().selAccountId;
      final account = context.read<AccountsModel>().accounts.firstWhere(
            (a) => a.myAccId == accountId,
          );
      final response = await SipRepository.getAllSipUsers(account.sipServer);
      if (mounted && response.status == 'success') {
        setState(() => _teamMembers = response.data ?? []);
      }
    } catch (_) {}
  }

  Future<String> _userGreeting() async {
    final email = await SharedPrefs().getValue(Constants.EMAILID) ?? '';
    if (email.contains('@')) {
      final name = email.split('@').first.replaceAll('.', ' ');
      if (name.isNotEmpty) {
        return name[0].toUpperCase() + name.substring(1);
      }
    }
    return 'there';
  }

  @override
  Widget build(BuildContext context) {
    final layout = context.watch<LayoutProvider>();
    final recent = layout.logList.take(8).toList();
    final vmCount = layout.voiceMailList.length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder<String>(
            future: _userGreeting(),
            builder: (context, snap) => Text(
              'Good day, ${snap.data ?? '…'}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Organization communication overview',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 24),
          _StatsRow(
            callCount: layout.logList.length,
            vmCount: vmCount,
            teamCount: _teamMembers.length,
            onDial: widget.onOpenDialer,
            onHistory: widget.onOpenHistory,
            onVoicemail: widget.onOpenVoicemail,
            onDirectory: widget.onOpenDirectory,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: _RecentCallsPanel(
                    logs: recent,
                    eventBus: _eventBus,
                    onViewAll: widget.onOpenHistory,
                    onRefresh: _loadData,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: _TeamPanel(
                    members: _teamMembers.take(12).toList(),
                    eventBus: _eventBus,
                    onViewAll: widget.onOpenDirectory,
                    onRefresh: _loadTeam,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.callCount,
    required this.vmCount,
    required this.teamCount,
    required this.onDial,
    required this.onHistory,
    required this.onVoicemail,
    required this.onDirectory,
  });

  final int callCount;
  final int vmCount;
  final int teamCount;
  final VoidCallback onDial;
  final VoidCallback onHistory;
  final VoidCallback onVoicemail;
  final VoidCallback onDirectory;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(
          label: 'Place call',
          value: 'Dial',
          icon: Icons.dialpad,
          accent: ThemeProvider.primaryTeal,
          onTap: onDial,
          isAction: true,
        )),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(
          label: 'Call history',
          value: '$callCount',
          icon: Icons.history,
          onTap: onHistory,
        )),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(
          label: 'Voicemail',
          value: vmCount > 0 ? '$vmCount new' : 'Inbox',
          icon: Icons.voicemail,
          onTap: onVoicemail,
          badge: vmCount > 0,
        )),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(
          label: 'Team directory',
          value: '$teamCount',
          icon: Icons.groups,
          onTap: onDirectory,
        )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.accent,
    this.isAction = false,
    this.badge = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final Color? accent;
  final bool isAction;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? ThemeProvider.cardDark;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Icon(icon, color: isAction ? Colors.white : ThemeProvider.accentTeal, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: isAction ? 16 : 20,
                        fontWeight: FontWeight.bold,
                        color: isAction ? Colors.white : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentCallsPanel extends StatelessWidget {
  const _RecentCallsPanel({
    required this.logs,
    required this.eventBus,
    required this.onViewAll,
    required this.onRefresh,
  });

  final List<CallLogResponse> logs;
  final EventTaxi eventBus;
  final VoidCallback onViewAll;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return _DesktopPanel(
      title: 'Recent calls',
      onViewAll: onViewAll,
      onRefresh: onRefresh,
      child: logs.isEmpty
          ? const Center(
              child: Text('No call history yet', style: TextStyle(color: Colors.white54)),
            )
          : ListView.separated(
              itemCount: logs.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.white.withValues(alpha: 0.06),
              ),
              itemBuilder: (context, i) {
                final log = logs[i];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    log.src.length <= 4 ? Icons.call_made : Icons.call_received,
                    color: ThemeProvider.accentTeal,
                    size: 20,
                  ),
                  title: Text(log.dstCnam.isNotEmpty ? log.dstCnam : log.dst),
                  subtitle: Text(
                    log.getFormattedCallDate(),
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: TextButton.icon(
                    onPressed: () {
                      final n = log.dst;
                      if (n.isNotEmpty) {
                        eventBus.fire(PlaceCallEvent(n, placeCall: true));
                      }
                    },
                    icon: const Icon(Icons.call, size: 16),
                    label: const Text('Call'),
                  ),
                );
              },
            ),
    );
  }
}

class _TeamPanel extends StatelessWidget {
  const _TeamPanel({
    required this.members,
    required this.eventBus,
    required this.onViewAll,
    required this.onRefresh,
  });

  final List<SIPUser> members;
  final EventTaxi eventBus;
  final VoidCallback onViewAll;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return _DesktopPanel(
      title: 'Team directory',
      onViewAll: onViewAll,
      onRefresh: onRefresh,
      child: members.isEmpty
          ? const Center(child: Text('Loading team…', style: TextStyle(color: Colors.white54)))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.8,
              ),
              itemCount: members.length,
              itemBuilder: (context, i) {
                final u = members[i];
                return Material(
                  color: ThemeProvider.surfaceDark,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => eventBus.fire(PlaceCallEvent(u.extension, placeCall: true)),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: ThemeProvider.primaryTeal.withValues(alpha: 0.3),
                            child: Text(
                              u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  u.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  'Ext. ${u.extension}',
                                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _DesktopPanel extends StatelessWidget {
  const _DesktopPanel({
    required this.title,
    required this.child,
    required this.onViewAll,
    required this.onRefresh,
  });

  final String title;
  final Widget child;
  final VoidCallback onViewAll;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeProvider.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(onPressed: onViewAll, child: const Text('View all')),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: onRefresh,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
          Expanded(child: child),
        ],
      ),
    );
  }
}
