import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/calls_model.dart';
import 'package:siprix_voip_sdk/devices_model.dart';
import 'package:siprix_voip_sdk/logs_model.dart';
import 'package:siprix_voip_sdk/siprix_voip_sdk.dart';
import 'package:siprix_voip_sdk/video.dart';

import '../../main.dart';
import '../models/call_model.dart';
import '../providers/layout_provider.dart';
import '../widget/dialpad_widget.dart';

enum CallAction { accept, reject, switchTo, hangup, hold, redirect }

class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  Timer? _callDurationTimer;

  void _toggleDurationTimer(AppCallsModel calls) {
    if (calls.isEmpty) {
      _callDurationTimer?.cancel();
      _callDurationTimer = null;
    } else {
      if (_callDurationTimer != null) return;
      _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        calls.calcDuration();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final calls = context.watch<AppCallsModel>();
    CallModel? switchedCall = calls.switchedCall();
    _toggleDurationTimer(calls);

    if (calls.isEmpty) return DialpadWidget(false);

    return Column(
      children: [
        const Divider(height: 1),
        ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.all(0.0),
          itemCount: calls.length,
          scrollDirection: Axis.vertical,
          separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
          itemBuilder: (BuildContext context, int index) {
            return ListenableBuilder(
              listenable: calls[index],
              builder: (BuildContext context, Widget? child) {
                return _callModelRowTile(calls, index);
              },
            );
          },
        ),
        const Divider(height: 1),
        if (switchedCall != null)
          Expanded(child: SwitchedCallWidget(switchedCall, key: ValueKey(switchedCall.myCallId))),
      ],
    );
  } //build

  ListTile _callModelRowTile(AppCallsModel calls, int index) {
    final call = calls[index];
    final bool isSwitched = (calls.switchedCallId == call.myCallId);

    return ListTile(
      selected: isSwitched,
      selectedColor: Colors.black,
      selectedTileColor: Colors.grey.shade300,
      leading: Icon(call.isIncoming ? Icons.call_received_rounded : Icons.call_made_rounded, color: isSwitched ? Colors.black : Colors.white54),
      title: Text(
        call.nameAndExt,
        style: TextStyle(fontWeight: (isSwitched ? FontWeight.bold : FontWeight.normal), color:isSwitched ? Colors.black: Colors.white54),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(call.state.name, style: TextStyle(color: isSwitched ? Colors.black : Colors.white54)),
      trailing:
          isSwitched
              ? null
              : IconButton(
                icon: const Icon(Icons.swap_calls_rounded, color: Colors.white54),
                onPressed: () {
                  calls.switchToCall(call.myCallId);
                },
              ),
      dense: true,
    );
  }
}


//SwitchedCallWidget - provides controls for manipulating current/switched call
class SwitchedCallWidget extends StatefulWidget {
  const SwitchedCallWidget(this.myCall, {super.key});

  final CallModel myCall;

  @override
  State<SwitchedCallWidget> createState() => _SwitchedCallWidgetState();
}

class _SwitchedCallWidgetState extends State<SwitchedCallWidget> {
  final SiprixVideoRenderer _localRenderer = SiprixVideoRenderer();
  final SiprixVideoRenderer _remoteRenderer = SiprixVideoRenderer();
  static const double eIconSize = 30;
  bool _isRecording = false;

  EventTaxi eventBus = EventTaxiImpl.singleton();

  bool _sendDtmfMode = false;

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
      builder: (BuildContext context, Widget? child) {
        return Stack(
          children: [
            ..._buildVideoControls(),
            Center(
              child: Column(
                children: [
                  const Spacer(),
                  _buildCallStateText(),
                  _buildFromToText(),
                  _buildCallDuration(),
                  const Spacer(),
                  ..._buildCallControls(),
                  const Spacer(),
                  if (widget.myCall.state == CallState.ringing) _buildIncomingCallAcceptReject(),
                  if (widget.myCall.state != CallState.ringing) _buildHangupButton(),
                  const Spacer(),
                ],
              ),
            ),
          ],
        );
      },
    );
  } //build

  Text _buildCallStateText() {
    return Text(widget.myCall.nameAndExt, style: Theme.of(context).textTheme.titleLarge);
  }

  Widget _buildFromToText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('${widget.myCall.state.name}', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 10),
      ],
    );
  }

  List<Widget> _buildVideoControls() {
    List<Widget> children = [];
    if (widget.myCall.hasVideo) {
      //Received video
      children.add(Center(child: SiprixVideoView(_remoteRenderer)));

      //Camera preview
      children.add(SizedBox(width: 130, height: 100, child: SiprixVideoView(_localRenderer)));

      //Button 'Mute camera'
      children.add(
        IconButton(
          onPressed: _muteCam,
          iconSize: eIconSize,
          icon: Icon(
            widget.myCall.isCamMuted ? Icons.videocam_off_outlined : Icons.videocam_outlined,
          ),
        ),
      );
    }
    return children;
  }

  List<Widget> _buildCallControls() {
    List<Widget> children = [];

    if ((widget.myCall.state != CallState.connected) &&
        (widget.myCall.state != CallState.holding) &&
        (widget.myCall.state != CallState.held)) {
      return children;
    }

    if (_sendDtmfMode) {
      children.add(_buildSendDtmf());
      return children;
    }

    final bool isCallConnected = (widget.myCall.state == CallState.connected);

    children.add(
      Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          buildIconButton(Icons.mic_off_rounded, _muteMic),
          buildIconButton(Icons.dialpad_rounded, isCallConnected ? _toggleSendDtmfMode : null),
          
          MenuAnchor(
            builder: (BuildContext context, MenuController controller, Widget? child) {
              return buildIconButton(Icons.volume_up, () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
              );
            },
            menuChildren: _buildPlayoutDevicesMenu(),
          ),
        ],
      ),
    );

    children.add(const SizedBox(height: 10));

    children.add(
      Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          buildIconButton(Icons.add, _showAddCallPage),
          buildIconButton(widget.myCall.isLocalHold ? Icons.play_arrow : Icons.pause, (widget.myCall.state == CallState.holding) ? null : _holdCall),
           
          buildIconButton(Icons.fiber_manual_record_outlined, isCallConnected ? _handleRecord : null),
        
        ],
      ),
    );

    children.add(const SizedBox(height: 10));
    children.add(
      Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
        
          buildIconButton(Icons.forward_outlined, isCallConnected ? () => _openCallTransferPopup(context) : null),
        
          buildIconButton(Icons.group_outlined, isCallConnected ? _makeConference : null),
        ],
      ),
    );

    return children;
  }

  Widget buildIconButton(IconData icon, VoidCallback? onPressed) {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(5),
          fixedSize: Size(eIconSize*1.5, eIconSize*1.5),
          shape: const CircleBorder(),
          side: BorderSide.none,
          backgroundColor: Colors.grey.withOpacity(0.1),
        ),
        onPressed: onPressed,
        child: Center(child: Icon(icon, size: eIconSize, color: Colors.white54)),
      );
    }

  void _openCallTransferPopup(BuildContext context) {
    final callsModel = context.read<AppCallsModel>();
    TextEditingController _transferController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Transfer Call', style: Theme.of(context).textTheme.titleMedium),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Transfer Blind", style: TextStyle(color: Colors.blue)),
              TextField(
                controller: _transferController,
                onSubmitted: (value) {
                  _transferBlind(value);
                  Navigator.of(context).pop();
                },
                decoration: InputDecoration(
                  hintText: "Extension number",
                  suffix: IconButton(
                    tooltip: "Transer Blind",
                    onPressed: () {
                      _transferBlind(_transferController.text);
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_right_alt),
                  ),
                ),
              ),
              if (callsModel.hasConnectedFewCalls()) const SizedBox(height: 20),
              if (callsModel.hasConnectedFewCalls())
                Text("Transfer to existing call", style: TextStyle(color: Colors.blue)),
              for (int i = 0; i < callsModel.length; i++)
                if (callsModel[i].myCallId != widget.myCall.myCallId &&
                    callsModel[i].state == CallState.connected)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(callsModel[i].nameAndExt),
                    trailing: IconButton(
                      onPressed: () {
                        _transferAttended(callsModel[i].myCallId);
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_right_alt),
                    ),
                  ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  _handleRecord() async {
    widget.myCall.sendDtmf('*');
    _isRecording = !_isRecording;
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.myCall.sendDtmf('1');
    });
  }


  Text _buildCallDuration() {
    String label;
    switch (widget.myCall.state) {
      case CallState.connected:
        label = widget.myCall.durationStr;
        break;
      case CallState.held:
        label = "On Hold (${widget.myCall.holdState.name})";
        break;
      default:
        label = "-:-";
    }
    return Text(
      label,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green),
    );
  }

  Widget _buildIncomingCallAcceptReject() {
    return Wrap(
      spacing: 50,
      runSpacing: 10,
      children: [
        IconButton.filledTonal(
          onPressed: _rejectCall,
          icon: const Icon(Icons.call_end),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
        IconButton.filledTonal(
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
    final bool enabled = (widget.myCall.state != CallState.disconnecting);
    return IconButton.filledTonal(
      iconSize: eIconSize,
      icon: const Icon(Icons.call_end),
      style: OutlinedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
      onPressed: enabled ? _hangUpCall : null,
      color: Colors.red,
    );
  }

  void showSnackBar(dynamic err) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
  }

  List<MenuItemButton> _buildPlayoutDevicesMenu() {
    final devices = context.watch<DevicesModel>();
    return [
      for (var dvc in devices.playout)
        MenuItemButton(
          onPressed: () {
            _setPlayoutDevice(dvc.index);
          },
          child: Text(dvc.name),
        ),
    ];
  }

  void _setPlayoutDevice(int index) {
    final devices = context.read<DevicesModel>();
    devices.setPlayoutDevice(index).catchError(showSnackBar);
  }

  void _hangUpCall() {
    final mprovider = Provider.of<LayoutProvider>(context, listen: false);
    widget.myCall.bye().catchError(showSnackBar);
    mprovider.clearCall(true);
    mprovider.goToDialPad();
  }

  void _acceptCall() {
    widget.myCall.accept(widget.myCall.hasVideo).catchError(showSnackBar);
  }

  void _rejectCall() {
    final mprovider = Provider.of<LayoutProvider>(context, listen: false);
    widget.myCall.reject().catchError(showSnackBar);
    widget.myCall.bye().catchError(showSnackBar);
    mprovider.clearCall(true);
    mprovider.goToDialPad();
  }

  void _sendDtmf(String tone) {
    widget.myCall.sendDtmf(tone).catchError(showSnackBar);
  }

  void _holdCall() {
    widget.myCall.hold().catchError(showSnackBar);
  }

  void _muteMic() {
    widget.myCall.muteMic(!widget.myCall.isMicMuted).catchError(showSnackBar);
  }

  void _muteCam() {
    widget.myCall.muteCam(!widget.myCall.isCamMuted).catchError(showSnackBar);
  }

  void _recordFile() async {
    if (widget.myCall.isRecStarted) {
      widget.myCall.stopRecordFile().catchError(showSnackBar);
    } else {
      String pathToFile = await MyApp.getRecFilePathName(widget.myCall.myCallId);
      widget.myCall.recordFile(pathToFile).catchError(showSnackBar);
    }
  }

  void _playFile() async {
    String pathToFile = await MyApp.writeAssetAndGetFilePath(
      "music.mp3",
    ); //write 'asset/music.mp3' to temp folder
    widget.myCall.playFile(pathToFile).catchError(showSnackBar);
  }

  void _makeConference() {
    final calls = context.read<AppCallsModel>();
    // final calls = context.read<CallsModel>();
    if (calls.hasConnectedFewCalls()) {
      calls.makeConference().catchError(showSnackBar);

      showSnackBar("Conference started");
    } else {
      showSnackBar("Should have at least 2 connected calls to make conference");
    }
  }

  void _transferBlind(String ext) async {
    widget.myCall.transferBlind(ext).catchError(showSnackBar);
  }

  void _transferAttended(int? toCallId) async {
    if (toCallId == null) return;

    widget.myCall.transferAttended(toCallId).catchError(showSnackBar);
  }

  void _showAddCallPage() {
    Navigator.of(context).pushNamed(DialpadWidget.routeName);
    final mprovider = Provider.of<LayoutProvider>(context, listen: false);
    mprovider.goToDialPad();
  }

  void _toggleSendDtmfMode() {
    setState(() => _sendDtmfMode = !_sendDtmfMode);
  }

  Widget _buildSendDtmf() {
    const double spacing = 8;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: spacing),
        Wrap(
          spacing: spacing,
          children: <Widget>[
            OutlinedButton(
              child: const Text('1', style: TextStyle(color: Colors.white54)),
              onPressed: () {
                _sendDtmf("1");
              },
            ),
            OutlinedButton(
              child: const Text('2', style: TextStyle(color: Colors.white54)),
              onPressed: () {
                _sendDtmf("2");
              },
            ),
            OutlinedButton(
              child: const Text('3', style: TextStyle(color: Colors.white54)),
              onPressed: () {
                _sendDtmf("3");
              },
            ),
          ],
        ),
        const SizedBox(height: spacing),
        Wrap(
          spacing: spacing,
          children: <Widget>[
            OutlinedButton(
              child: const Text('4', style: TextStyle(color: Colors.white54)),
              onPressed: () {
                _sendDtmf("4");
              },
            ),
            OutlinedButton(
              child: const Text('5', style: TextStyle(color: Colors.white54)),
              onPressed: () {
                _sendDtmf("5");
              },
            ),
            OutlinedButton(
              child: const Text('6', style: TextStyle(color: Colors.white54)),
              onPressed: () {
                _sendDtmf("6");
              },
            ),
          ],
        ),
        const SizedBox(height: spacing),
        Wrap(
          spacing: spacing,
          children: <Widget>[
            OutlinedButton(
              child: const Text('7', style: TextStyle(color: Colors.white54)),
              onPressed: () {
                _sendDtmf("7");
              },
            ),
            OutlinedButton(
              child: const Text('8', style: TextStyle(color: Colors.white54)),
              onPressed: () {
                _sendDtmf("8");
              },
            ),
            OutlinedButton(
              child: const Text('9', style: TextStyle(color: Colors.white54)),
              onPressed: () {
                _sendDtmf("9");
              },
            ),
          ],
        ),
        const SizedBox(height: spacing),
        Wrap(
          spacing: spacing,
          children: <Widget>[
            OutlinedButton(
              child: const Text('*', style: TextStyle(color: Colors.white54)),
              onPressed: () {
                _sendDtmf("*");
              },
            ),
            OutlinedButton(
              child: const Text('0', style: TextStyle(color: Colors.white54)),
              onPressed: () {
                _sendDtmf("0");
              },
            ),
            OutlinedButton(
              child: const Text('#', style: TextStyle(color: Colors.white54)),
              onPressed: () {
                _sendDtmf("#");
              },
            ),
          ],
        ),
        const SizedBox(height: spacing),
        buildIconButton(Icons.close, _toggleSendDtmfMode),
      ],
    );
  }
} //_CallsPageState
