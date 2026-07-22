import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/call_model.dart';
import '../widget/dialpad_widget.dart';
import '../widget/mobile_call_controls.dart';

/// Mobile phone tab — embedded dialpad when idle, classic in-call controls when active.
class MobileCallPage extends StatefulWidget {
  const MobileCallPage({super.key});

  @override
  State<MobileCallPage> createState() => _MobileCallPageState();
}

class _MobileCallPageState extends State<MobileCallPage> {
  Timer? _durationTimer;

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  void _syncDurationTimer(AppCallsModel calls) {
    if (calls.isEmpty) {
      _durationTimer?.cancel();
      _durationTimer = null;
    } else if (_durationTimer == null) {
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) => calls.calcDuration());
    }
  }

  @override
  Widget build(BuildContext context) {
    final calls = context.watch<AppCallsModel>();
    _syncDurationTimer(calls);
    final switched = calls.switchedCall();

    if (calls.isEmpty) return const DialpadWidget(false);

    return Column(
      children: [
        const Divider(height: 1),
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: calls.length,
          scrollDirection: Axis.vertical,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return ListenableBuilder(
              listenable: calls[index],
              builder: (context, _) => _callRow(calls, index),
            );
          },
        ),
        const Divider(height: 1),
        if (switched != null)
          Expanded(
            child: MobileCallControls(switched, key: ValueKey(switched.myCallId)),
          ),
      ],
    );
  }

  ListTile _callRow(AppCallsModel calls, int index) {
    final call = calls[index];
    final isSwitched = calls.switchedCallId == call.myCallId;

    return ListTile(
      selected: isSwitched,
      selectedColor: Colors.black,
      selectedTileColor: Colors.grey.shade300,
      leading: Icon(
        call.isIncoming ? Icons.call_received_rounded : Icons.call_made_rounded,
        color: isSwitched ? Colors.black : Colors.white54,
      ),
      title: Text(
        call.nameAndExt,
        style: TextStyle(
          fontWeight: isSwitched ? FontWeight.bold : FontWeight.normal,
          color: isSwitched ? Colors.black : Colors.white54,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        call.state.name,
        style: TextStyle(color: isSwitched ? Colors.black : Colors.white54),
      ),
      trailing: isSwitched
          ? null
          : IconButton(
              icon: const Icon(Icons.swap_calls_rounded, color: Colors.white54),
              onPressed: () => calls.switchToCall(call.myCallId),
            ),
      dense: true,
    );
  }
}
