import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:callingproject/src/api_response/call_log_response.dart';
import 'package:callingproject/src/utils/layout_util.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../event/CallAnalyticsUpdatedEvent.dart';
import '../event/place_call_event.dart';
import '../event/refresh_call_log_event.dart';
import '../providers/call_logs_provider.dart';
import '../providers/layout_provider.dart';
enum CallAction { accept, reject, switchTo, hangup, hold, redirect }

enum CdrAction { delete, deleteAll }

class LogListScreen extends StatefulWidget {
  const LogListScreen({super.key});

  @override
  State<LogListScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogListScreen> {
  EventTaxi eventBus = EventTaxiImpl.singleton();
  final ScrollController _scrollController = ScrollController();

  final player = AudioPlayer();
  String recordingFile = '';
  bool isPlaying = false;

  Timer? _timer;

  String mExtentionNumber = "";
  final Key _visibilityDetectorKey = UniqueKey();
  StreamSubscription<RefreshCallLogEvent>? refreshCallLogSubscription;
  StreamSubscription<CallAnalyticsUpdatedEvent>? callAnalyticsUpdatedSubscription;

  @override
  void initState() {
    final selectedAccountId = context.read<AccountsModel>().selAccountId;
    final selectedAccount = context.read<AccountsModel>().accounts.firstWhere(
      (element) => element.myAccId == selectedAccountId,
    );
    mExtentionNumber = selectedAccount.sipExtension;

    final provider = Provider.of<LayoutProvider>(context, listen: false);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        provider.getCallLogs(selectedAccount.sipServer, mExtentionNumber);
      }
    });

    // Run task every 5 minutes
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      provider.getNewCallLogs(selectedAccount.sipServer, mExtentionNumber);
    });

    player.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.completed) {
        isPlaying = false;
        recordingFile = '';
        setState(() {});
      }
    });

    callAnalyticsUpdatedSubscription = eventBus.registerTo<CallAnalyticsUpdatedEvent>(false).listen((event) async {
      for (var callLog in provider.logList) {
        if (callLog.getRecordingFile().contains(event.recording_file)) {
          callLog.is_call_summary = event.is_call_summary;
        }
      }
      setState(() {});
    });


    refreshCallLogSubscription = eventBus.registerTo<RefreshCallLogEvent>(false).listen((event) {
      if (event.isUpdate) {
        Future.delayed(Duration(seconds: 2), () {
          provider.getNewCallLogs(selectedAccount.sipServer, mExtentionNumber);
        });
      }
    });
    provider.getCallLogs(selectedAccount.sipServer, mExtentionNumber, isFirstTime: true);

    super.initState();
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;
    player.stop();
    isPlaying = false;
    setState(() {

    });
  }

  goToCallAnalytics(CallLogResponse cdrs) {
    final selectedAccountId = context.read<AccountsModel>().selAccountId;
    final selectedAccount = context.read<AccountsModel>().accounts.firstWhere(
      (element) => element.myAccId == selectedAccountId,
    );
   launchUrl(Uri.parse("http://" + selectedAccount.sipServer + ":3000/call-analytics/" + cdrs.recordingfile.split("/").last));
  }

  @override
  Widget build(BuildContext context) {
    
    final mCallProvider = Provider.of<CallProvider>(context);
    return VisibilityDetector(
        onVisibilityChanged: _handleVisibilityChanged,
        key: _visibilityDetectorKey,
        child: Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(16),

      child: Column(
        children: [
          Consumer<LayoutProvider>(
            builder: (context, provider, _) {
              return Expanded(
                child:  Container(
                      height: LayoutUtil.isMobile() ? null : 500,
                      width: double.infinity,
                      child:
                          LayoutUtil.isMobile()
                              ? _buildMobileLayout(
                                context,
                                provider,
                                mCallProvider,
                              )
                              : _buildDesktopLayout(
                                context,
                                provider,
                                mCallProvider,
                              ),
                    )
                  
                );
            }
              
            
          ),
        ],
      ),
        ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    player.dispose();
    refreshCallLogSubscription?.cancel();
    callAnalyticsUpdatedSubscription?.cancel();
    super.dispose();
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    LayoutProvider provider,
    CallProvider mCallProvider,
  ) {
    if (provider.logList.isEmpty) {
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
    return ListView.builder(
      controller: _scrollController,
      itemCount: provider.logList.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (provider.hasMore && index == provider.logList.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final cdrs = provider.logList[index];
        return Container(
          key: ValueKey(cdrs.did),
          constraints: BoxConstraints(minHeight: 50),
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                cdrs.getFormattedCallIcon(mExtentionNumber),
                SizedBox(width: 10),
                Container(
                  width: 90,
                  child: InkWell(
                    onTap: () {
                      if (cdrs.src == mExtentionNumber ||
                          cdrs.channel.contains(mExtentionNumber)) {
                        mCallProvider.phoneNumbCtrl.text = cdrs.dst.toString();
                      } else {
                        mCallProvider.phoneNumbCtrl.text = cdrs.src.toString();
                      }
                    },
                    child: Text(cdrs.getFormattedCallExtension(mExtentionNumber),
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Container(
                  width: 110,
                  child: Text(
                    provider.getFormattedCallStatusName(cdrs),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: provider.getCallLogColor(cdrs),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Text(
                  cdrs.getFormattedCallDate(),
                  style: TextStyle(color: Colors.white.withOpacity(1)),
                ),

                // call button
                Spacer(),
                if (cdrs.recordingfile != '' && cdrs.disposition.contains('ANSWERED'))
                  InkWell(
                    onTap: () {
                      if (player.state == PlayerState.playing) {
                        player.stop();
                        isPlaying = false;
                        recordingFile = '';
                        setState(() {});
                      } else {
                        player.play(UrlSource(cdrs.getRecordingFile()));
                        player.getDuration();
                        isPlaying = true;
                        recordingFile = cdrs.getRecordingFile();
                        setState(() {});
                      }
                    },
                    child: Icon(
                      isPlaying && recordingFile == cdrs.getRecordingFile()
                          ? Icons.stop
                          : Icons.play_arrow,
                    ),
                  ),

                if (cdrs.is_call_summary)
                  SizedBox(width: 15),
                if (cdrs.is_call_summary)
                  InkWell(
                    onTap: () {
                      goToCallAnalytics(cdrs);
                    
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      child: Image.asset('assets/ai.png'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    LayoutProvider provider,
    CallProvider mCallProvider,
  ) {
    if (provider.logList.isEmpty) {
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
    return ListView.builder(
      controller: _scrollController,
      itemCount: provider.logList.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (provider.hasMore && index == provider.logList.length) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final cdrs = provider.logList[index];
        return Container(
          key: ValueKey(cdrs.did),
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IntrinsicHeight(
            child: Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                cdrs.getFormattedCallIcon(mExtentionNumber),
                Expanded(
                  flex: 2,
                  child:  InkWell(
                      onTap: () {
                        if (cdrs.src == mExtentionNumber ||
                            cdrs.channel.contains(mExtentionNumber)) {
                          mCallProvider.phoneNumbCtrl.text = cdrs.dst.toString();
                          eventBus.fire(PlaceCallEvent(cdrs.dst));
                        } else {
                          mCallProvider.phoneNumbCtrl.text = cdrs.src.toString();
                          eventBus.fire(PlaceCallEvent(cdrs.src));
                        }
                      },
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                     Text(
                          cdrs.src == mExtentionNumber || cdrs.channel.contains(mExtentionNumber)
                              ? cdrs.dst
                              : "${cdrs.cnam} (${cdrs.src})",
                          style: TextStyle(fontSize: 14),
                        ),

                      Text(
                          provider.getFormattedCallStatusName(cdrs),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: provider.getCallLogColor(cdrs),
                          ),
                        ),

                    ],
                  ))
                ),
                Expanded(
                  flex: 3,
                  child:  Text(
                    cdrs.getFormattedCallDate(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(1)
                    ),
                  ),
                ),

                // call button
                SizedBox(width: 10),
                if (cdrs.recordingfile != '' && cdrs.disposition.contains('ANSWERED'))
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      tooltip: 'Recording',
                      onPressed: () {
                        if (player.state == PlayerState.playing) {
                          player.stop();
                          isPlaying = false;
                          recordingFile = '';
                          setState(() {});
                        } else {
                          player.play(UrlSource(cdrs.getRecordingFile()));
                          player.getDuration();
                          isPlaying = true;
                          recordingFile = cdrs.getRecordingFile();
                          setState(() {});
                        }
                      },
                      icon: Icon(
                        isPlaying && recordingFile == cdrs.getRecordingFile()
                            ? Icons.stop
                            : Icons.play_arrow,
                      ),
                    ),
                  )
                else
                  Expanded(flex: 1, child: SizedBox()),

                if (cdrs.is_call_summary)
                  Expanded(flex: 1,
                      child: InkWell(
                        onTap: () {
                          goToCallAnalytics(cdrs);
                        
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          child: Image.asset('assets/ai.png'),
                        ),
                      )),
              ],
            ),
          ),
        );
      },
    );
  }
}
