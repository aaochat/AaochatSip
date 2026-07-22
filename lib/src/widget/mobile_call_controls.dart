import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/calls_model.dart';
import 'package:siprix_voip_sdk/devices_model.dart';
import 'package:siprix_voip_sdk/logs_model.dart';
import 'package:siprix_voip_sdk/siprix_voip_sdk.dart';
import 'package:siprix_voip_sdk/video.dart';

import '../models/call_model.dart';
import '../providers/call_logs_provider.dart';
import '../providers/layout_provider.dart';
import '../utils/snackbar_util.dart';
import 'dialpad_widget.dart';

/// Classic mobile in-call UI — icon grid layout (distinct from desktop ActiveCallControls).
class MobileCallControls extends StatefulWidget {
  const MobileCallControls(this.myCall, {super.key});

  final CallModel myCall;

  @override
  State<MobileCallControls> createState() => _MobileCallControlsState();
}

class _MobileCallControlsState extends State<MobileCallControls> {
  final SiprixVideoRenderer _localRenderer = SiprixVideoRenderer();
  final SiprixVideoRenderer _remoteRenderer = SiprixVideoRenderer();
  bool _isRecording = false;
  bool _sendDtmfMode = false;

  static const double _iconSize = 40;

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
          children: [
            ..._buildVideoControls(),
            Center(
              child: Column(
                children: [
                  const Spacer(),
                  Text(
                    widget.myCall.nameAndExt,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(widget.myCall.state.name),
                  const SizedBox(height: 8),
                  Text(
                    _durationLabel(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  const Spacer(),
                  if (_sendDtmfMode) _buildDtmfPad() else ..._buildCallControls(),
                  const Spacer(),
                  if (widget.myCall.state == CallState.ringing)
                    _buildIncomingActions()
                  else
                    _buildHangupButton(),
                  const Spacer(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildVideoControls() {
    if (!widget.myCall.hasVideo) return [];
    return [
      Center(child: SiprixVideoView(_remoteRenderer)),
      Positioned(
        top: 8,
        right: 8,
        child: SizedBox(
          width: 130,
          height: 100,
          child: SiprixVideoView(_localRenderer),
        ),
      ),
      Positioned(
        top: 8,
        left: 8,
        child: IconButton(
          onPressed: _muteCam,
          icon: Icon(
            widget.myCall.isCamMuted ? Icons.videocam_off_outlined : Icons.videocam_outlined,
          ),
        ),
      ),
    ];
  }

  String _durationLabel() {
    switch (widget.myCall.state) {
      case CallState.connected:
        return widget.myCall.durationStr;
      case CallState.held:
        return 'On Hold (${widget.myCall.holdState.name})';
      default:
        return '-:-';
    }
  }

  List<Widget> _buildCallControls() {
    final connected = widget.myCall.state == CallState.connected;
    final holding =
        widget.myCall.state == CallState.holding || widget.myCall.state == CallState.held;
    if (!connected && !holding) return [];

    return [
      Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          _iconButton(
            widget.myCall.isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            _muteMic,
          ),
          _iconButton(Icons.dialpad_rounded, connected ? _toggleDtmf : null),
          _iconButton(Icons.volume_up, _showSpeakerMenu),
        ],
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          _iconButton(Icons.add, _showAddCall),
          _iconButton(
            widget.myCall.isLocalHold ? Icons.play_arrow : Icons.pause,
            connected ? _holdCall : null,
          ),
          _iconButton(
            _isRecording ? Icons.fiber_manual_record : Icons.fiber_manual_record_outlined,
            connected ? _handleRecord : null,
            color: _isRecording ? Colors.green : null,
          ),
        ],
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          _iconButton(Icons.forward_outlined, connected ? () => _openTransfer(context) : null),
          _iconButton(Icons.group_outlined, connected ? _makeConference : null),
        ],
      ),
    ];
  }

  Widget _iconButton(IconData icon, VoidCallback? onPressed, {Color? color}) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(5),
        fixedSize: const Size(_iconSize * 2, _iconSize * 2),
        shape: const CircleBorder(),
        side: BorderSide.none,
        backgroundColor: Colors.grey.withValues(alpha: 0.1),
      ),
      onPressed: onPressed,
      child: Icon(icon, size: _iconSize, color: color ?? Colors.white54),
    );
  }

  Widget _buildIncomingActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          padding: const EdgeInsets.all(_iconSize / 2.3),
          iconSize: _iconSize,
          onPressed: _rejectCall,
          icon: const Icon(Icons.call_end),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 50),
        IconButton.filledTonal(
          padding: const EdgeInsets.all(_iconSize / 2.3),
          iconSize: _iconSize,
          onPressed: _acceptCall,
          icon: const Icon(Icons.call),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildHangupButton() {
    if (widget.myCall.state == CallState.ringing) return const SizedBox.shrink();
    final enabled = widget.myCall.state != CallState.disconnecting;
    return IconButton.filledTonal(
      padding: const EdgeInsets.all(_iconSize / 2.3),
      iconSize: _iconSize,
      icon: const Icon(Icons.call_end),
      style: OutlinedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
      onPressed: enabled ? _hangUpCall : null,
    );
  }

  Widget _buildDtmfPad() {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          for (final k in keys)
            OutlinedButton(
              onPressed: () => _sendDtmf(k),
              child: Text(k, style: const TextStyle(color: Colors.white54)),
            ),
          _iconButton(Icons.close, _toggleDtmf),
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
        title: const Text('Transfer Call'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Transfer Blind'),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Extension number'),
              onSubmitted: (v) {
                _transferBlind(v);
                Navigator.pop(ctx);
              },
            ),
            if (callsModel.hasConnectedFewCalls()) ...[
              const SizedBox(height: 16),
              const Text('Transfer to existing call'),
              for (var i = 0; i < callsModel.length; i++)
                if (callsModel[i].myCallId != widget.myCall.myCallId &&
                    callsModel[i].state == CallState.connected)
                  ListTile(
                    title: Text(callsModel[i].nameAndExt),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_right_alt),
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
    context.read<LayoutProvider>().goToDialPad();
  }

  void _rejectCall() {
    widget.myCall.reject().catchError(_showError);
    widget.myCall.bye().catchError(_showError);
    context.read<LayoutProvider>().clearCall(true);
    context.read<LayoutProvider>().goToDialPad();
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
      _showError('Should have at least 2 connected calls to make conference');
    }
  }

  void _showAddCall() {
    context.read<CallProvider>().clearText();
    Navigator.of(context).pushNamed(DialpadWidget.routeName);
    context.read<LayoutProvider>().goToDialPad();
  }
}
