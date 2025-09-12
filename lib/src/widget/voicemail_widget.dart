
import 'package:audioplayers/audioplayers.dart' as audioPlayer;
import 'dart:async';
import 'package:callingproject/src/api_response/api_response.dart';
import 'package:callingproject/src/event/refresh_voice_mail_event.dart';
import 'package:callingproject/src/models/voice_mail_log.dart';
import 'package:callingproject/src/repository/sip_repository.dart';
import 'package:callingproject/src/utils/layout_util.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
    getVoiceMailList();

    refreshVoiceMailSubscription = eventBus
        .registerTo<RefreshVoiceMailEvent>(false)
        .listen((event) {
          getVoiceMailList();
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
    return VisibilityDetector(
        onVisibilityChanged: _handleVisibilityChanged,
        key: _visibilityDetectorKey,
        child: Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(16),
      child: ListView.separated(
        itemBuilder:
            (context, index) => Container(
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
                            voiceMailList[index].caller_id,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            voiceMailList[index].getFormattedDate(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    if (!LayoutUtil.isMobile())
                      Text(
                        voiceMailList[index].caller_id,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (!LayoutUtil.isMobile())
                      Text(
                        voiceMailList[index].getFormattedDate(),
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    Spacer(),
                    InkWell(
                      child: Icon(
                        isPlaying &&
                                recordingFile ==
                                    voiceMailList[index].getVoiceMailFile()
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
                              voiceMailList[index].getVoiceMailFile(),
                            ),
                          );
                          player.getDuration();
                          isPlaying = true;
                          recordingFile =
                              voiceMailList[index].getVoiceMailFile();
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
        separatorBuilder: (context, index) => SizedBox(height: 10),
        itemCount: voiceMailList.length,
      ),
        ));
  }
}
