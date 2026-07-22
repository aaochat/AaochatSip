import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/calls_model.dart';
import 'package:siprix_voip_sdk/devices_model.dart';
import 'package:siprix_voip_sdk/logs_model.dart';
import 'package:siprix_voip_sdk/siprix_voip_sdk.dart';
import 'package:siprix_voip_sdk/video.dart';

import '../Providers/theme_provider.dart';
import '../models/call_model.dart';
import '../providers/call_logs_provider.dart';
import '../providers/layout_provider.dart';
import '../utils/snackbar_util.dart';
import 'dialpad_widget.dart';

/// Redesigned in-call UI — avatar header + bottom action bar (distinct from template grid).
class ActiveCallControls extends StatefulWidget {
  const ActiveCallControls(this.myCall, {super.key});

  final CallModel myCall;

  @override
  State<ActiveCallControls> createState() => _ActiveCallControlsState();
}

class _ActiveCallControlsState extends State<ActiveCallControls> {
  final SiprixVideoRenderer _localRenderer = SiprixVideoRenderer();
  final SiprixVideoRenderer _remoteRenderer = SiprixVideoRenderer();
  bool _isRecording = false;
  bool _sendDtmfMode = false;

  static double get _iconSize => Platform.isAndroid || Platform.isIOS ? 28.0 : 24.0;

  @override
  void initState() {
    super.initState();
    _localRenderer.init(SiprixVoipSdk.kLocalVideoCallId, context.read<LogsModel>());
    _remoteRenderer.init(widget.myCall.myCallId, context.read<LogsModel>());
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.myCall,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            if (widget.myCall.hasVideo) ...[
              Positioned.fill(child: SiprixVideoView(_remoteRenderer)),
              Positioned(
                top: 16,
                right: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 100,
                    height: 76,
                    child: SiprixVideoView(_localRenderer),
                  ),
                ),
              ),
            ],
            Column(
              children: [
                const SizedBox(height: 24),
                _buildHeader(),
                const Spacer(),
                if (_sendDtmfMode) _buildDtmfPad() else _buildActionBar(),
                const SizedBox(height: 16),
                if (widget.myCall.state == CallState.ringing)
                  _buildIncomingActions()
                else
                  _buildHangupButton(),
                const SizedBox(height: 24),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    final name = widget.myCall.nameAndExt;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: ThemeProvider.primaryTeal.withValues(alpha: 0.35),
          child: Text(
            initial,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Text(name, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(
          widget.myCall.state.name,
          style: const TextStyle(color: Colors.white54),
        ),
        const SizedBox(height: 8),
        Text(
          _durationLabel(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ThemeProvider.accentTeal,
          ),
        ),
      ],
    );
  }

  String _durationLabel() {
    switch (widget.myCall.state) {
      case CallState.connected:
        return widget.myCall.durationStr;
      case CallState.held:
        return 'On hold';
      default:
        return '';
    }
  }

  Widget _buildActionBar() {
    final connected = widget.myCall.state == CallState.connected;
    final holding = widget.myCall.state == CallState.holding || widget.myCall.state == CallState.held;
    if (!connected && !holding) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: ThemeProvider.cardDark.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _actionChip(
              widget.myCall.isMicMuted ? Icons.mic_off : Icons.mic,
              'Mute',
              _muteMic,
            ),
            _actionChip(Icons.dialpad, 'Keypad', connected ? _toggleDtmf : null),
            _actionChip(Icons.volume_up, 'Speaker', _showSpeakerMenu),
            _actionChip(Icons.add_call, 'Add', connected ? _showAddCall : null),
            _actionChip(
              widget.myCall.isLocalHold ? Icons.play_arrow : Icons.pause,
              'Hold',
              connected ? _holdCall : null,
            ),
            _actionChip(
              _isRecording ? Icons.fiber_manual_record : Icons.fiber_manual_record_outlined,
              'Record',
              connected ? _handleRecord : null,
              active: _isRecording,
            ),
            _actionChip(Icons.phone_forwarded, 'Transfer', connected ? () => _openTransfer(context) : null),
            _actionChip(Icons.groups, 'Merge', connected ? _makeConference : null),
            if (widget.myCall.hasVideo)
              _actionChip(
                widget.myCall.isCamMuted ? Icons.videocam_off : Icons.videocam,
                'Video',
                _muteCam,
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionChip(IconData icon, String label, VoidCallback? onTap, {bool active = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: onTap == null ? 0.4 : 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: active
                      ? ThemeProvider.primaryTeal
                      : Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: _iconSize, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomingActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton.large(
            heroTag: 'reject',
            backgroundColor: Colors.red.shade700,
            onPressed: _rejectCall,
            child: const Icon(Icons.call_end),
          ),
          FloatingActionButton.large(
            heroTag: 'accept',
            backgroundColor: Colors.green.shade700,
            onPressed: _acceptCall,
            child: const Icon(Icons.call),
          ),
        ],
      ),
    );
  }

  Widget _buildHangupButton() {
    if (widget.myCall.state == CallState.ringing) return const SizedBox.shrink();
    final enabled = widget.myCall.state != CallState.disconnecting;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton.icon(
          onPressed: enabled ? _hangUpCall : null,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          ),
          icon: const Icon(Icons.call_end),
          label: const Text('End Call'),
        ),
      ),
    );
  }

  Widget _buildDtmfPad() {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          for (final k in keys)
            SizedBox(
              width: 64,
              height: 48,
              child: OutlinedButton(
                onPressed: () => _sendDtmf(k),
                child: Text(k),
              ),
            ),
          TextButton(onPressed: _toggleDtmf, child: const Text('Close keypad')),
        ],
      ),
    );
  }

  void _showSpeakerMenu() {
    final devices = context.read<DevicesModel>().playout;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('Select speaker')),
            for (final d in devices)
              ListTile(
                title: Text(d.name),
                onTap: () {
                  context.read<DevicesModel>().setPlayoutDevice(d.index).catchError(_showError);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _openTransfer(BuildContext context) {
    final callsModel = context.read<AppCallsModel>();
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Forward call'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Extension or number'),
              keyboardType: TextInputType.phone,
              onSubmitted: (v) {
                _transferBlind(v);
                Navigator.pop(ctx);
              },
            ),
            if (callsModel.hasConnectedFewCalls()) ...[
              const SizedBox(height: 16),
              const Text('Or transfer to active call:'),
              for (var i = 0; i < callsModel.length; i++)
                if (callsModel[i].myCallId != widget.myCall.myCallId &&
                    callsModel[i].state == CallState.connected)
                  ListTile(
                    title: Text(callsModel[i].nameAndExt),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        _transferAttended(callsModel[i].myCallId);
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              _transferBlind(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Forward'),
          ),
        ],
      ),
    );
  }

  void _showError(dynamic err) => showAppSnackBar(context, message: err.toString());
  void _sendDtmf(String t) => widget.myCall.sendDtmf(t).catchError(_showError);
  void _muteMic() => widget.myCall.muteMic(!widget.myCall.isMicMuted).catchError(_showError);
  void _muteCam() => widget.myCall.muteCam(!widget.myCall.isCamMuted).catchError(_showError);
  void _holdCall() => widget.myCall.hold().catchError(_showError);
  void _acceptCall() => widget.myCall.accept(widget.myCall.hasVideo).catchError(_showError);
  void _toggleDtmf() => setState(() => _sendDtmfMode = !_sendDtmfMode);

  void _handleRecord() {
    widget.myCall.sendDtmf('*');
    setState(() => _isRecording = !_isRecording);
    Future.delayed(const Duration(milliseconds: 100), () => widget.myCall.sendDtmf('1'));
  }

  void _hangUpCall() {
    widget.myCall.bye().catchError(_showError);
    context.read<LayoutProvider>().clearCall(true);
  }

  void _rejectCall() {
    widget.myCall.reject().catchError(_showError);
    widget.myCall.bye().catchError(_showError);
    context.read<LayoutProvider>().clearCall(true);
  }

  void _transferBlind(String ext) => widget.myCall.transferBlind(ext).catchError(_showError);
  void _transferAttended(int? id) {
    if (id != null) widget.myCall.transferAttended(id).catchError(_showError);
  }

  void _makeConference() {
    final calls = context.read<AppCallsModel>();
    if (calls.hasConnectedFewCalls()) {
      calls.makeConference().catchError(_showError);
    } else {
      _showError('Need at least two connected calls to merge');
    }
  }

  void _showAddCall() {
    context.read<CallProvider>().clearText();
    Navigator.of(context).pushNamed(DialpadWidget.routeName);
  }
}

/// Active call session page — multi-call list + [ActiveCallControls].
class CallSessionPage extends StatefulWidget {
  const CallSessionPage({super.key});

  @override
  State<CallSessionPage> createState() => _CallSessionPageState();
}

class _CallSessionPageState extends State<CallSessionPage> {
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

    if (calls.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        if (calls.length > 1)
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: calls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 4),
              itemBuilder: (context, index) {
                final call = calls[index];
                final selected = calls.switchedCallId == call.myCallId;
                return ChoiceChip(
                  label: Text(call.nameAndExt, overflow: TextOverflow.ellipsis),
                  selected: selected,
                  onSelected: (_) => calls.switchToCall(call.myCallId),
                );
              },
            ),
          ),
        if (switched != null)
          Expanded(
            child: ActiveCallControls(switched, key: ValueKey(switched.myCallId)),
          ),
      ],
    );
  }
}
