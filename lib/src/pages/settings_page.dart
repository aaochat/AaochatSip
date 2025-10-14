import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/devices_model.dart';
import 'package:siprix_voip_sdk/siprix_voip_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/call_logs_provider.dart';
import '../utils/Constants.dart';
import '../utils/extension_util.dart';
import '../utils/shared_prefs.dart';
import '../utils/snackbar_util.dart';
import 'domain_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

typedef OnChangedCallback = void Function(int?);

class _SettingsPageState extends State<SettingsPage> {

  var _mCallProvider = CallProvider();

  @override
  void didChangeDependencies() {
    _mCallProvider = Provider.of<CallProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final devices = context.watch<DevicesModel>();
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Device Settings ----------
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Audio/Video Settings",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // Playout device
                    _buildPlayoutDevicesDropDown(devices),
                    const SizedBox(height: 20),
                    _buildRecordingDevicesDropDown(devices),
                    const SizedBox(height: 20),
                    _buildVideoDevicesDropDown(devices),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              elevation: 3,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip, color: Colors.blue),
                    title: const Text("Privacy Policy"),
                    onTap: () {
                      launchUrl(Uri.parse("https://voip-api.aaochat.com/privacy-policy"));
                    },
                  ),
                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.orange),
                    title: const Text("Logout"),
                    onTap: () {
                      showLogoutDialog(context, _mCallProvider);
                    },
                  ),
                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text("Delete Account"),
                    onTap: () {
                      ShowDeleteDialog();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPrivacyPolicy() async {
    final Uri url = Uri.parse('https://voip-api.aaochat.com/privacy-policy');
    if (await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void deleteAccount() async {
    mLogoutSession(context.read<CallProvider>());
  }

  void ShowDeleteDialog() {
    showDialog(
      context: context,
      builder:
          (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            backgroundColor: Colors.white,
            title: Text('Delete Account',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
            content: Text(
                'Are you sure you want to delete your account?',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                )),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),

              // TextButton(
              //   onPressed: () {
              //     deleteAccount();
              //   },
              //   child: const Text('Delete', style: TextStyle(color: Colors.red)),
              // ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  deleteAccount();
                },
                child: Text("Delete"),
              ),
            ],
          ),
    );
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
    showAppSnackBar(context, message: err);
  }

  Future<void> requestMicPermissions() async {
    var mic = await Permission.microphone.request();
    if (mic.isGranted) {
      print("🎤 Mic permission granted");
    } else {
      print("❌ Mic permission denied");
    }
  }

  // Future<void> mLogoutSession(CallProvider mCallProvider) async {
  //   await mCallProvider.DeleteAccountApiCalling(context);
  //   await ExtensionUtil.deleteAllAccounts(context);
  //   await SharedPrefs().clear();
  //     Navigator.pushAndRemoveUntil(
  //       context,
  //       MaterialPageRoute(builder: (context) => Domainscreen()),
  //       ModalRoute.withName("/Login"),
  //     );
  // }

  Future<void> showLogoutDialog(BuildContext context, CallProvider mCallProvider) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap a button
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Icon(Icons.logout, color: Colors.redAccent),
                SizedBox(width: 8),
                Text(
                  "Confirm Logout",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Text(
                "Are you sure you want to logout?",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                )
            ),
            actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12,),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  mLogoutSession(mCallProvider);
                },
                child: Text("Logout"),
              ),
            ],
          ),
    );
  }

  Future<void> mLogoutSession(CallProvider mCallProvider) async {
    await mCallProvider.logout();
    await ExtensionUtil.deleteAllAccounts(context);
    await SharedPrefs().clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => Domainscreen(),
      ),
      ModalRoute.withName("/Login"),
    );
  }
}
