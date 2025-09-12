import 'package:audioplayers/audioplayers.dart' as audioPlayer;
import 'package:callingproject/src/api_response/api_response.dart';
import 'package:callingproject/src/models/voice_mail_log.dart';
import 'package:callingproject/src/repository/sip_repository.dart';
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

  @override
  void initState() {
    getVoiceMailList();
    super.initState();
  }

  getVoiceMailList() async {
    isLoading = true;

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
    setState(() {});
  }

  @override
  void dispose() {
    player.dispose();
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Text(
                      voiceMailList[index].getFormattedDate(),
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                    SizedBox(width: 10),
                    Text(
                      voiceMailList[index].caller_id,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        isPlaying &&
                                recordingFile ==
                                    voiceMailList[index].getVoiceMailFile()
                            ? Icons.stop
                            : Icons.play_arrow,
                      ),
                      onPressed: () {
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
