
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';

import '../Providers/theme_provider.dart';
import '../event/place_call_event.dart';
import '../models/sip_user_model.dart';
import '../repository/sip_repository.dart';
import '../utils/snackbar_util.dart';

/// Organization extension directory — distinct from dialpad typeahead-only lookup.
class DirectoryPage extends StatefulWidget {
  const DirectoryPage({super.key});

  @override
  State<DirectoryPage> createState() => _DirectoryPageState();
}

class _DirectoryPageState extends State<DirectoryPage> {
  List<SIPUser> _allUsers = [];
  List<SIPUser> _filtered = [];
  bool _loading = true;
  final _searchController = TextEditingController();
  final _eventBus = EventTaxiImpl.singleton();

  @override
  void initState() {
    super.initState();
    _loadDirectory();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDirectory() async {
    setState(() => _loading = true);
    try {
      final accountId = context.read<AccountsModel>().selAccountId;
      final account = context.read<AccountsModel>().accounts.firstWhere(
            (a) => a.myAccId == accountId,
          );
      final response = await SipRepository.getAllSipUsers(account.sipServer);
      if (!mounted) return;
      if (response.status == 'success') {
        _allUsers = response.data ?? [];
        _applyFilter();
      } else {
        showAppSnackBar(context, message: response.message ?? 'Could not load directory');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(_allUsers)
          : _allUsers
              .where(
                (u) =>
                    u.name.toLowerCase().contains(q) ||
                    u.extension.contains(q),
              )
              .toList();
    });
  }

  void _callExtension(SIPUser user) {
    _eventBus.fire(PlaceCallEvent(user.extension, placeCall: true));
    showAppSnackBar(context, message: 'Calling ${user.name}…');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search team by name or extension',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: ThemeProvider.cardDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Team Directory',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadDirectory,
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _filtered.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'No team members found'
                            : 'No matches for "${_searchController.text}"',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final user = _filtered[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: ThemeProvider.primaryTeal.withValues(alpha: 0.3),
                              child: Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: ThemeProvider.accentTeal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(user.name),
                            subtitle: Text('Ext. ${user.extension}'),
                            trailing: IconButton(
                              icon: Icon(Icons.call, color: ThemeProvider.accentTeal),
                              onPressed: () => _callExtension(user),
                            ),
                            onTap: () => _callExtension(user),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
