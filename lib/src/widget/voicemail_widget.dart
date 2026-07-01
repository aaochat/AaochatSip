import 'dart:async';

import 'package:audioplayers/audioplayers.dart' as audioPlayer;
import 'package:aaochat_sip/src/api_response/api_response.dart';
import 'package:aaochat_sip/src/event/refresh_voice_mail_event.dart';
import 'package:aaochat_sip/src/models/voice_mail_log.dart';
import 'package:aaochat_sip/src/repository/sip_repository.dart';
import 'package:aaochat_sip/src/utils/layout_util.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../providers/layout_provider.dart';

class VoicemailWidget extends StatefulWidget {
  VoicemailWidget({Key? key}) : super(key: key);

  @override
  _VoicemailWidgetState createState() => _VoicemailWidgetState();
}

class _VoicemailWidgetState extends State<VoicemailWidget> {
  List<VoiceMailLog> voiceMailList = [];
  bool isLoading = false;

  final player = audioPlayer.AudioPlayer();
  String recordingFile = '';
  bool isPlaying = false;

  final Key _visibilityDetectorKey = UniqueKey();

  EventTaxi eventBus = EventTaxiImpl.singleton();
  StreamSubscription<RefreshVoiceMailEvent>? refreshVoiceMailSubscription;

  @override
  void initState() {
    final provider = Provider.of<LayoutProvider>(context, listen: false);
    provider.getVoiceMailList(context);

    refreshVoiceMailSubscription = eventBus
        .registerTo<RefreshVoiceMailEvent>(false)
        .listen((event) {
      provider.getVoiceMailList(context);
    });

    player.onPlayerStateChanged.listen((event) {
      if (event == audioPlayer.PlayerState.completed) {
        isPlaying = false;
        recordingFile = '';
        setState(() {
        });
      }
    });

    super.initState();
  }

  getVoiceMailList() async {
    if (isLoading) return;
    isLoading = true;

    try {
      final selectedAccountId = context.read<AccountsModel>().selAccountId;
      final selectedAccount = context.read<AccountsModel>().accounts.firstWhere(
        (element) => element.myAccId == selectedAccountId,
      );

      ApiResponse<List<VoiceMailLog>> response =
          await SipRepository.getVoiceMailList(
            selectedAccount.sipServer,
            selectedAccount.sipExtension,
          );
      if (response.status == "success" && response.data != null) {
        voiceMailList = response.data ?? [];
      }
      isLoading = false;
    } catch (e) {
      print(e);
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    player.dispose();
    refreshVoiceMailSubscription?.cancel();
    super.dispose();
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;
    player.stop();
    isPlaying=false;
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LayoutProvider>(context, listen: false);
    if (provider.voiceMailList.isEmpty) {
      return const Center(
        child: Text(
          "No records found",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      );
    }
    return VisibilityDetector(
        onVisibilityChanged: _handleVisibilityChanged,
        key: _visibilityDetectorKey,
        child: Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(16),
          child: Consumer<LayoutProvider>(
              builder: (context, provider, _) {
                return ListView.separated(
                  itemBuilder:
                      (context, index) =>
                      Container(
                        constraints: BoxConstraints(minHeight: 50),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            spacing: 20,
                            children: [
                              if (LayoutUtil.isMobile())
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider.voiceMailList[index].caller_id,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      provider.voiceMailList[index].getFormattedDate(),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              if (!LayoutUtil.isMobile())
                                Text(
                                  provider.voiceMailList[index].caller_id,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (!LayoutUtil.isMobile())
                                Text(
                                  provider.voiceMailList[index].getFormattedDate(),
                                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                ),
                              Spacer(),
                              InkWell(
                                child: Icon(
                                  isPlaying &&
                                      recordingFile ==
                                          provider.voiceMailList[index].getVoiceMailFile()
                                      ? Icons.stop
                                      : Icons.play_arrow,
                                ),
                                onTap: () {
                                  if (player.state == audioPlayer.PlayerState.playing) {
                                    player.stop();
                                    isPlaying = false;
                                    recordingFile = '';
                                    setState(() {});
                                  } else {
                                    player.play(
                                      audioPlayer.UrlSource(
                                        provider.voiceMailList[index].getVoiceMailFile(),
                                      ),
                                    );
                                    player.getDuration();
                                    isPlaying = true;
                                    recordingFile =
                                        provider.voiceMailList[index].getVoiceMailFile();
                                    setState(() {});
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                  separatorBuilder: (context, index) => SizedBox(height: 10),
                  itemCount:  provider.voiceMailList.length,
                );
              }),
        ));
  }
}
