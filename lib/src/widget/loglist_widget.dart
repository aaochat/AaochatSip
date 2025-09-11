import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:callingproject/src/Databased/calllog_history.dart';
import 'package:callingproject/src/utils/layout_util.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/cdrs_model.dart';

import '../api_response/call_log_response.dart';
import '../event/PlaceCallEvent.dart';
import '../event/refresh_call_log_event.dart';
import '../providers/call_logs_provider.dart';
import '../providers/layout_provider.dart';
import '../utils/Constants.dart';
import '../utils/shared_prefs.dart';

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
  String mSip_usernam = "";

  final player = AudioPlayer();
  String recordingFile = '';
  bool isPlaying = false;

  Timer? _timer;

  String mExtentionNumber = "";

  @override
  void initState() {
    final selectedAccountId = context.read<AccountsModel>().selAccountId;
    final selectedAccount = context.read<AccountsModel>().accounts.firstWhere(
      (element) => element.myAccId == selectedAccountId,
    );
    mExtentionNumber = selectedAccount.sipExtension;
    print('mExtentionNumber: $mExtentionNumber');

    final provider = Provider.of<LayoutProvider>(context, listen: false);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        provider.ApiCalling(mExtentionNumber);
      }
    });

    // Run task every 5 minutes
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      print('refreshApiCalling');
      provider.refreshApiCalling(mExtentionNumber);
    });

    player.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.completed) {
        isPlaying = false;
        recordingFile = '';
      }
    });

    eventBus.registerTo<RefreshCallLogEvent>(false).listen((event) {
      if (event.isUpdate) {
        Future.delayed(Duration(seconds: 2), () {
          provider.refreshApiCalling(mExtentionNumber);
        });
      }
    });
    provider.ApiCalling(mExtentionNumber, isFirstTime: true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    final mCallProvider = Provider.of<CallProvider>(context);
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(16),

      child: Column(
        children: [
          Consumer<LayoutProvider>(
            builder: (context, provider, _) {
              return Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
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
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    LayoutProvider provider,
    CallProvider mCallProvider,
  ) {
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
                    child: Text(
                      cdrs.src == mExtentionNumber ||
                              cdrs.channel.contains(mExtentionNumber)
                          ? cdrs.dst
                          : "${cdrs.cnam} (${cdrs.src})",
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
                if (cdrs.recordingfile != '')
                  IconButton(
                    tooltip: 'Recording',
                    onPressed: () {
                      if (player.state == PlayerState.playing) {
                        player.stop();
                        isPlaying = false;
                        recordingFile = '';
                      } else {
                        player.play(UrlSource(cdrs.getRecordingFile()));
                        player.getDuration();
                        isPlaying = true;
                        recordingFile = cdrs.getRecordingFile();
                      }
                    },
                    icon: Icon(
                      isPlaying && recordingFile == cdrs.getRecordingFile()
                          ? Icons.stop
                          : Icons.play_arrow,
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
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: InkWell(
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
                    child: Text(
                      cdrs.src == mExtentionNumber
                          ? cdrs.dst
                          : "${cdrs.cnam}\n(${cdrs.src})",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Text(
                    provider.getFormattedCallStatusName(cdrs),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: provider.getCallLogColor(cdrs),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: Column(
                    spacing: 1,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        provider.convertDateFormat(cdrs.calldate),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withOpacity(1)
                                  : Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // call button
                SizedBox(width: 10),
                if (cdrs.recordingfile != '')
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
                        } else {
                          player.play(UrlSource(cdrs.getRecordingFile()));
                          player.getDuration();
                          isPlaying = true;
                          recordingFile = cdrs.getRecordingFile();
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
              ],
            ),
          ),
        );
      },
    );
  }
}
