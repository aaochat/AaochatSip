import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/devices_model.dart';
import 'package:siprix_voip_sdk/siprix_voip_sdk.dart';

import '../providers/call_logs_provider.dart';
import '../utils/Constants.dart';
import '../utils/extension_util.dart';
import '../utils/layout_util.dart';
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
  static const double _desktopContentMaxWidth = 560;

  @override
  Widget build(BuildContext context) {
    final devices = context.watch<DevicesModel>();
    final theme = Theme.of(context);
    final isDesktop = !LayoutUtil.isMobile();

    return Scaffold(
      backgroundColor:
          isDesktop ? const Color(0xFF121212) : theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: isDesktop ? 0 : null,
        title: const Text('Settings'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 40 : 20,
            isDesktop ? 28 : 20,
            isDesktop ? 40 : 20,
            isDesktop ? 40 : 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? _desktopContentMaxWidth : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildBody(devices, isDesktop, theme),
            ),
          ),
        ),
      ),
    );
  }

  void deleteAccount() async {
    mLogoutSession(context.read<CallProvider>());
  }

  List<Widget> _buildBody(
    DevicesModel devices,
    bool isDesktop,
    ThemeData theme,
  ) {
    return [
      if (isDesktop) _buildIntroHeader(theme),
      if (isDesktop) const SizedBox(height: 20),
      _deviceSettingsCard(devices, isDesktop, theme),
      SizedBox(height: isDesktop ? 24 : 20),
      _deleteAccountSection(isDesktop),
    ];
  }

  Widget _buildIntroHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Devices',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose speakers, microphone, and camera for calls on this machine.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white60,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _deviceSettingsCard(
    DevicesModel devices,
    bool isDesktop,
    ThemeData theme,
  ) {
    final cardChild = Padding(
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 22 : 4,
        isDesktop ? 20 : 0,
        isDesktop ? 22 : 4,
        isDesktop ? 8 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isDesktop) ...[
            Text(
              'Audio & video',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
          ],
          _deviceRow(
            icon: Icons.volume_up_outlined,
            child: _buildPlayoutDevicesDropDown(devices, isDesktop),
          ),
          SizedBox(height: isDesktop ? 18 : 20),
          _deviceRow(
            icon: Icons.mic_none_outlined,
            child: _buildRecordingDevicesDropDown(devices, isDesktop),
          ),
          SizedBox(height: isDesktop ? 18 : 20),
          _deviceRow(
            icon: Icons.videocam_outlined,
            child: _buildVideoDevicesDropDown(devices, isDesktop),
          ),
        ],
      ),
    );

    if (!isDesktop) {
      return cardChild;
    }

    return Material(
      color: Colors.grey.shade900,
      elevation: 1,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: cardChild,
    );
  }

  Widget _deviceRow({required IconData icon, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 14),
          child: Icon(icon, size: 22, color: Colors.white54),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _deleteAccountSection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isDesktop) ...[
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          const SizedBox(height: 20),
          Text(
            'Account',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Align(
          alignment: isDesktop ? Alignment.centerLeft : Alignment.center,
          child: isDesktop
              ? OutlinedButton.icon(
                onPressed: _showDeleteAccountDialog,
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                label: const Text('Delete account'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
              : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.red),
                    ),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _showDeleteAccountDialog,
                  child: const Text('Delete Account'),
                ),
              ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text(
            'Delete account',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete your account?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                deleteAccount();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  DropdownMenuItem<int> mediaDeviceItem(MediaDevice dvc) {
    return DropdownMenuItem<int>(
      value: dvc.index,
      child: Text(dvc.name, style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  InputDecoration _dropdownDecoration(
    String labelText,
    bool isDesktop,
  ) {
    if (isDesktop) {
      return InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.25),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.deepOrangeAccent, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Colors.white60),
        floatingLabelStyle: const TextStyle(color: Colors.deepOrangeAccent),
      );
    }

    return InputDecoration(
      border: const UnderlineInputBorder(),
      labelText: labelText,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildMediaDevicesDropDown(
    String labelText,
    List<MediaDevice> dvcList,
    int selIndex,
    OnChangedCallback onChanged,
    bool isDesktop,
  ) {
    return DropdownButtonFormField<int>(
      isExpanded: true,
      dropdownColor: const Color(0xFF2C2C2C),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Colors.white.withValues(alpha: 0.95),
      ),
      iconEnabledColor: Colors.white54,
      decoration: _dropdownDecoration(labelText, isDesktop),
      value: selIndex < 0 ? null : selIndex,
      onChanged: onChanged,
      items: dvcList.map((element) => mediaDeviceItem(element)).toList(),
    );
  }

  Widget _buildPlayoutDevicesDropDown(DevicesModel devices, bool isDesktop) {
    return _buildMediaDevicesDropDown(
      'Playout device',
      devices.playout,
      devices.playoutIndex,
      onSetPlayoutDevice,
      isDesktop,
    );
  }

  Widget _buildRecordingDevicesDropDown(DevicesModel devices, bool isDesktop) {
    return _buildMediaDevicesDropDown(
      'Recording device',
      devices.recording,
      devices.recordingIndex,
      onSetRecordingDevice,
      isDesktop,
    );
  }

  Widget _buildVideoDevicesDropDown(DevicesModel devices, bool isDesktop) {
    return _buildMediaDevicesDropDown(
      'Video device',
      devices.video,
      devices.videoIndex,
      onSetVideoDevice,
      isDesktop,
    );
  }

  Future<void> onSetPlayoutDevice(int? index) async {
    context.read<DevicesModel>().setPlayoutDevice(index).catchError(showSnackBar);
    await SharedPrefs().setValue(
      Constants.SIP_PLAYOUT_DEVICE,
      context.read<DevicesModel>().playout[index!].name,
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

  Future<void> mLogoutSession(CallProvider mCallProvider) async {
    await mCallProvider.DeleteAccountApiCalling(context);
    await ExtensionUtil.deleteAllAccounts(context);
    await SharedPrefs().clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Domainscreen()),
      ModalRoute.withName("/Login"),
    );
  }
}
