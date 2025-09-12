import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/devices_model.dart';
import 'package:siprix_voip_sdk/siprix_voip_sdk.dart';

import '../providers/call_logs_provider.dart';
import '../utils/Constants.dart';
import '../utils/shared_prefs.dart';
import 'domain_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

typedef OnChangedCallback = void Function(int?);

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final devices = context.watch<DevicesModel>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        surfaceTintColor: Colors.grey.shade900,
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildBody(devices),
        ),
      ),
    );
  }

  void deleteAccount() async {
    mLogoutSession(context.read<CallProvider>());
  }

  List<Widget> _buildBody(DevicesModel devices) {
    if (Platform.isIOS) {
      return [const Text('iOS doesn\'t have settings yet')];
    } else if (Platform.isAndroid) {
      return [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          title: const Text('Run phone service in foreground mode'),
          value: devices.foregroundModeEnabled,
          onChanged: onSetForegroundMode,
        ),
      ];
    } else {
      return [
        _buildPlayoutDevicesDropDown(devices),
        const SizedBox(height: 20),
        _buildRecordingDevicesDropDown(devices),
        const SizedBox(height: 20),
        _buildVideoDevicesDropDown(devices),
        const SizedBox(height: 20),
        // DeleteAccountButton()
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.red),
            ),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text('Are you sure you want to delete your account?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteAccount();
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
            );
          },
          child: const Text('Delete Account'),
        ),
      ];
    }
  }

  DropdownMenuItem<int> mediaDeviceItem(MediaDevice dvc) {
    return DropdownMenuItem<int>(
      value: dvc.index,
      child: Text(dvc.name, style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  Widget _buildMediaDevicesDropDown(
    String labelText,
    List<MediaDevice> dvcList,
    int selIndex,
    OnChangedCallback onChanged,
  ) {
    return ButtonTheme(
      alignedDropdown: true,
      child: DropdownButtonFormField<int>(
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: labelText,
          contentPadding: const EdgeInsets.all(0),
        ),
        value: (selIndex < 0) ? null : selIndex,
        onChanged: onChanged,
        items: dvcList.map((element) => mediaDeviceItem(element)).toList(),
      ),
    );
  }

  Widget _buildPlayoutDevicesDropDown(DevicesModel devices) {
    return _buildMediaDevicesDropDown(
      'Playout device:',
      devices.playout,
      devices.playoutIndex,
      onSetPlayoutDevice,
    );
  }

  Widget _buildRecordingDevicesDropDown(DevicesModel devices) {
    return _buildMediaDevicesDropDown(
      'Recording device:',
      devices.recording,
      devices.recordingIndex,
      onSetRecordingDevice,
    );
  }

  Widget _buildVideoDevicesDropDown(DevicesModel devices) {
    return _buildMediaDevicesDropDown(
      'Video device:',
      devices.video,
      devices.videoIndex,
      onSetVideoDevice,
    );
  }

  Future<void> onSetPlayoutDevice(int? index) async {
    context.read<DevicesModel>().setPlayoutDevice(index).catchError(showSnackBar);
    await SharedPrefs().setValue(
      Constants.SIP_PLAYOUT_DEVICE,
      context.read<DevicesModel>().recording[index!].name,
    );
  }

  Future<void> onSetRecordingDevice(int? index) async {
    context.read<DevicesModel>().setRecordingDevice(index).catchError(showSnackBar);

    await SharedPrefs().setValue(
      Constants.SIP_RECORDING_DEVICE,
      context.read<DevicesModel>().recording[index!].name,
    );
  }

  void onSetVideoDevice(int? index) {
    context.read<DevicesModel>().setVideoDevice(index).catchError(showSnackBar);
  }

  void onSetForegroundMode(bool enable) async {
    context.read<DevicesModel>().setForegroundMode(enable).catchError(showSnackBar);
  }

  void showSnackBar(dynamic err) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
  }

  Future<void> requestMicPermissions() async {
    var mic = await Permission.microphone.request();
    if (mic.isGranted) {
      print("🎤 Mic permission granted");
    } else {
      print("❌ Mic permission denied");
    }
  }

  Future<void> mLogoutSession(CallProvider mCallProvider) async {
    var response = await mCallProvider.DeleteAccountApiCalling(context);
    if (response) {
      try {
        for (int i = 0; i < context
            .read<AccountsModel>()
            .length; i++) {
          await context.read<AccountsModel>().deleteAccount(i);
        }
      } catch (e) {
        print(e);
      }
      await SharedPrefs().clear();
      mCallProvider.clearText();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Domainscreen()),
        ModalRoute.withName("/Login"),
      );
    }
  }
}
