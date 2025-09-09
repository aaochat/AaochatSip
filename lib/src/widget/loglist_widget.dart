import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:callingproject/src/Databased/calllog_history.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String currentMenu = 'call_logs';
  final ScrollController _scrollController = ScrollController();
  String mSip_usernam = "";
  String mExtentionNumber = SharedPrefs().getValue(Constants.EXTENSION_NUMBER);

  final player = AudioPlayer();
  String recordingFile = '';
  bool isPlaying = false;

  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(16),
        child: buildCdrsList(),
      ),
    );
  }

  @override
  void initState() {
    final provider = Provider.of<LayoutProvider>(context, listen: false);

    _scrollController.addListener(() {
      // if at bottom
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        provider.ApiCalling(context);
      }
    });

    // Run task every 5 minutes
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      provider.refreshApiCalling(context);
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
          provider.refreshApiCalling(context);
          /*TODO Api Calling*/
          //   /*Databased Update for Duration*/
          //   final provider = Provider.of<LayoutProvider>(context, listen: false);
          //   final mCardModel = context.read<CdrsModel>();
          //   mDuration = mCardModel[0].duration;
          //   provider.Updateduration(mDuration);
          //   log("Call_Update_Log:$mDuration");
        });
      }
    });
    provider.ApiCalling(context, isFirstTime: true);
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when widget disposed
    super.dispose();
  }

  Widget buildCdrsList() {
    /*IF Provider listen=true then it will update Durations and Status RealTime*/
    final provider = Provider.of<LayoutProvider>(context, listen: false);
    final mCallProvider = Provider.of<CallProvider>(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                changeCurrentMenu('call_logs');
              },
              child: Text(
                'Call Logs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      currentMenu == 'call_logs'
                          ? FontWeight.bold
                          : FontWeight.normal,
                  color:
                      currentMenu == 'call_logs' ? Colors.white : Colors.grey,
                ),
              ),
            ),
            // SizedBox(width: 15),
            // GestureDetector(
            //   onTap: () {
            //     changeCurrentMenu('voice_mails');
            //   },
            //   child: Text(
            //     'Voice Mails',
            //     style: TextStyle(
            //       fontSize: 20,
            //       fontWeight:
            //           currentMenu == 'voice_mails'
            //               ? FontWeight.bold
            //               : FontWeight.normal,
            //       color:
            //           currentMenu == 'voice_mails' ? Colors.white : Colors.grey,
            //     ),
            //   ),
            // ),
            Spacer(),
            InkWell(onTap: () async {
              final response = await provider.refreshApiCalling(context);

              if (response == "success") {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Updated successful!", style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold,),),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else if (response == "") {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("No new records found!", style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold,),),
                    backgroundColor: Colors.blueAccent,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(response ?? "failed!", style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold,),),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
              child: Icon(Icons.sync_outlined),)

          ],
        ),
        SizedBox(height: 15),
        // Expanded(
        //   child: ListView.separated(
        //     scrollDirection: Axis.vertical,
        //     itemCount: cdrs.length,
        //     itemBuilder: (BuildContext context, int index) {
        //       CdrModel cdr = cdrs[index];
        //       return ListTile(
        //         selected: (_selCdrRowIdx == index),
        //         selectedColor: Colors.black,
        //         selectedTileColor: Theme.of(context).secondaryHeaderColor,
        //         contentPadding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        //         leading: _getCdrIcon(cdr),
        //         title: _getCdrTitle(cdr),
        //         subtitle:
        //             (_selCdrRowIdx == index) ? _getCdrSubTitle(cdr) : null,
        //         trailing: _getCdrRowTrailing(cdr, index),
        //         dense: true,
        //         onTap: () {
        //           setState(() {
        //             context.read<AppAccountsModel>().setSelectedAccountByUri(
        //               cdr.accUri,
        //             );
        //             mCallProvider.phoneNumbCtrl.text = cdr.remoteExt;
        //             _selCdrRowIdx = index;
        //           });
        //         },
        //       );
        //     },
        //     separatorBuilder:
        //         (BuildContext context, int index) => const Divider(height: 0),
        //   ),
        // ),

        /*Todo Separate*/
        Consumer<LayoutProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error.isNotEmpty) {
                return Center(child: Text("Error: ${provider.error}"));
              }

              if (provider.logList.isEmpty) {
                return const Center(child: Text("No call logs available"));
              }

              return Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 600; // 📱 breakpoint

                    return Container(
                      height: isMobile ? null : 500,
                      width: double.infinity,
                      child: isMobile
                          ? _buildMobileLayout(context, provider, mCallProvider)
                          : _buildDesktopLayout(context, provider, mCallProvider),
                    );
                  },
                ),
              );
            }
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, LayoutProvider provider,
      CallProvider mCallProvider) {
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
            Theme
                .of(context)
                .brightness == Brightness.dark
                ? Colors.black
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [

                _getCdrIconsAndCall(cdrs),

                SizedBox(width: 10),
                Container(
                  width: 90,

                  // child: Text(
                  //   callLogs[index].getFormattedCallStatus(myExtensionNo),
                  //   style: TextStyle(
                  //     fontSize: 12,
                  //     color: callLogs[index].getCallLogColor(),
                  //   ),
                  // ),
                  child: InkWell(
                    onTap: () {
                      if (cdrs.src == mExtentionNumber) {
                        mCallProvider.phoneNumbCtrl.text =
                            cdrs.dst.toString();
                      } else {
                        mCallProvider.phoneNumbCtrl.text =
                            cdrs.src.toString();
                      }
                    },
                    child: Text(
                      cdrs.src == mExtentionNumber
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
                Column(
                  spacing: 2,
                  children: [
                    Text(
                      provider.convertDateFormat(cdrs.calldate),
                      style: TextStyle(
                        color:
                        Theme
                            .of(context)
                            .brightness ==
                            Brightness.dark
                            ? Colors.white.withOpacity(1)
                            : Colors.black.withOpacity(0.7),
                      ),
                    ),

                    Visibility(
                      visible: cdrs.disposition == "ANSWERED" ? true : false,
                      child: Text(
                        "Duration: ${formatDuration(cdrs.duration)}",
                        style: TextStyle(
                          color:
                          Theme
                              .of(context)
                              .brightness ==
                              Brightness.dark
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ),

                    // if (cdrs.statusCode != 0)
                    //   Text(
                    //     "Status code: ${cdrs.statusCode}",
                    //     style: TextStyle(
                    //       color:
                    //       Theme
                    //           .of(context)
                    //           .brightness ==
                    //           Brightness.dark
                    //           ? Colors.white.withOpacity(0.7)
                    //           : Colors.black.withOpacity(0.7),
                    //     ),
                    //   ),

                    // if (cdrs.hasVideo!)
                    //   const Icon(
                    //     Icons.videocam_outlined,
                    //     color: Colors.grey,
                    //     size: 18,
                    //   ),
                  ],
                ),

                /*Todo:Additional Functionality:-For added Caller name and Extension Number After Date*/
                // SizedBox(width: 15),
                // if (cdrs.src == mExtentionNumber)
                //   InkWell(
                //     onTap: () {
                //       eventBus.fire(PlaceCallEvent(cdrs.dst));
                //     },
                //     child: Text(
                //       provider.getCallDestinationName(cdrs),
                //       style: TextStyle(
                //         fontSize: 14,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   )
                // else
                //   InkWell(
                //     onTap: () {
                //       eventBus.fire(
                //         PlaceCallEvent(
                //           cdrs.src == mExtentionNumber
                //               ? cdrs.dst
                //               : cdrs.src,
                //         ),
                //       );
                //     },
                //     child: Text(
                //       '${cdrs.src} - ${cdrs.cnam}',
                //       style: TextStyle(
                //         fontSize: 14,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // Spacer(),
                /*End Era*/

                // call button
                SizedBox(width: 10),
                if (cdrs.recordingfile != '')
                  IconButton(
                    tooltip: 'Recording',
                    onPressed: () {
                      if (player.state == PlayerState.playing) {
                        player.stop();
                        isPlaying = false;
                        recordingFile = '';
                      } else {
                        player.play(
                          UrlSource(cdrs.getRecordingFile()),
                        );
                        player.getDuration();
                        isPlaying = true;
                        recordingFile =
                            cdrs.getRecordingFile();
                      }
                    },
                    icon: Icon(
                      isPlaying &&
                          recordingFile ==
                              cdrs.getRecordingFile()
                          ? Icons.stop
                          : Icons.play_arrow,
                    ),
                  )

                /*TODO: Delete Record*/
                // SizedBox(width: 10),
                // _getCdrRowTrailing(cdrs, index, provider),

                // create ticket button
                // if (callLogs[index].supportTicketMaster ==
                //     null)
                //   ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.grey.shade900,
                //       foregroundColor:
                //       Colors.white.withOpacity(0.5),
                //     ),
                //     onPressed: () {
                //       Get.find<LayoutController>()
                //           .goToCreateSupportTicket(
                //           callLogs[index].uniqueid);
                //     },
                //     child: Text('Create Ticket'),
                //   ),
                // if (callLogs[index].supportTicketMaster !=
                //     null)
                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.green,
                //     foregroundColor: Colors.black,
                //   ),
                //   onPressed: () {
                //     Get.dialog(
                //       SupportTicketDetailModal(
                //         supportTicketMaster: callLogs[index]
                //             .supportTicketMaster!,
                //       ),
                //     );
                //   },
                //   child: Text(
                //       '#${callLogs[index].supportTicketMaster?.ticket_id}'),
                // ),
              ]
              ,
            )
            ,
          )
          ,
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, LayoutProvider provider,
      CallProvider mCallProvider) {
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
            Theme
                .of(context)
                .brightness == Brightness.dark
                ? Colors.black
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [

                _getCdrIconsAndCall(cdrs),

                SizedBox(width: 10),
                Container(
                  // width: 90,
                  child: InkWell(
                    onTap: () {
                      if (cdrs.src == mExtentionNumber) {
                        mCallProvider.phoneNumbCtrl.text =
                            cdrs.dst.toString();
                        eventBus.fire(PlaceCallEvent(cdrs.dst));
                      } else {
                        mCallProvider.phoneNumbCtrl.text =
                            cdrs.src.toString();
                        eventBus.fire(PlaceCallEvent(cdrs.src));
                      }
                    },
                    child: Text(
                      cdrs.src == mExtentionNumber
                          ? cdrs.dst
                          : "${cdrs.cnam}\n(${cdrs.src})",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Container(
                  // width: 110,
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
                Expanded(
                    flex: 3,
                    child: Column(
                      spacing: 2,
                      children: [
                        Text(
                          provider.convertDateFormat(cdrs.calldate),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color:
                            Theme
                                .of(context)
                                .brightness ==
                                Brightness.dark
                                ? Colors.white.withOpacity(1)
                                : Colors.black.withOpacity(0.7),
                          ),
                        ),

                        Visibility(
                          visible: cdrs.disposition == "ANSWERED" ? true : false,
                          child: Text(
                            "Duration: ${formatDuration(cdrs.duration)}",
                            style: TextStyle(
                              color:
                              Theme
                                  .of(context)
                                  .brightness ==
                                  Brightness.dark
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.black.withOpacity(0.7),
                            ),
                          ),
                        ),

                        // if (cdrs.statusCode != 0)
                        //   Text(
                        //     "Status code: ${cdrs.statusCode}",
                        //     style: TextStyle(
                        //       color:
                        //       Theme
                        //           .of(context)
                        //           .brightness ==
                        //           Brightness.dark
                        //           ? Colors.white.withOpacity(0.7)
                        //           : Colors.black.withOpacity(0.7),
                        //     ),
                        //   ),

                        // if (cdrs.hasVideo!)
                        //   const Icon(
                        //     Icons.videocam_outlined,
                        //     color: Colors.grey,
                        //     size: 18,
                        //   ),
                      ],
                    )),

                /*Todo:Additional Functionality:-For added Caller name and Extension Number After Date*/
                // SizedBox(width: 15),
                // if (cdrs.src == mExtentionNumber)
                //   InkWell(
                //     onTap: () {
                //       eventBus.fire(PlaceCallEvent(cdrs.dst));
                //     },
                //     child: Text(
                //       provider.getCallDestinationName(cdrs),
                //       style: TextStyle(
                //         fontSize: 14,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   )
                // else
                //   InkWell(
                //     onTap: () {
                //       eventBus.fire(
                //         PlaceCallEvent(
                //           cdrs.src == mExtentionNumber
                //               ? cdrs.dst
                //               : cdrs.src,
                //         ),
                //       );
                //     },
                //     child: Text(
                //       '${cdrs.src} - ${cdrs.cnam}',
                //       style: TextStyle(
                //         fontSize: 14,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // Spacer(),
                /*End Era*/

                // call button
                SizedBox(width: 10),
                if (cdrs.recordingfile != '')
                  IconButton(
                    tooltip: 'Recording',
                    onPressed: () {
                      if (player.state == PlayerState.playing) {
                        player.stop();
                        isPlaying = false;
                        recordingFile = '';
                      } else {
                        player.play(
                          UrlSource(cdrs.getRecordingFile()),
                        );
                        player.getDuration();
                        isPlaying = true;
                        recordingFile =
                            cdrs.getRecordingFile();
                      }
                    },
                    icon: Icon(
                      isPlaying &&
                          recordingFile ==
                              cdrs.getRecordingFile()
                          ? Icons.stop
                          : Icons.play_arrow,
                    ),
                  )

                /*TODO: Delete Record*/
                // SizedBox(width: 10),
                // _getCdrRowTrailing(cdrs, index, provider),

                // create ticket button
                // if (callLogs[index].supportTicketMaster ==
                //     null)
                //   ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.grey.shade900,
                //       foregroundColor:
                //       Colors.white.withOpacity(0.5),
                //     ),
                //     onPressed: () {
                //       Get.find<LayoutController>()
                //           .goToCreateSupportTicket(
                //           callLogs[index].uniqueid);
                //     },
                //     child: Text('Create Ticket'),
                //   ),
                // if (callLogs[index].supportTicketMaster !=
                //     null)
                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.green,
                //     foregroundColor: Colors.black,
                //   ),
                //   onPressed: () {
                //     Get.dialog(
                //       SupportTicketDetailModal(
                //         supportTicketMaster: callLogs[index]
                //             .supportTicketMaster!,
                //       ),
                //     );
                //   },
                //   child: Text(
                //       '#${callLogs[index].supportTicketMaster?.ticket_id}'),
                // ),
              ]
              ,
            )
            ,
          )
          ,
        );
      },
    );
  }

  String formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (hours > 0) {
      return "$hours:$minutes:$seconds"; // hh:mm:ss
    } else {
      return "$minutes:$seconds"; // mm:ss
    }
  }

  changeCurrentMenu(menuwe) {
    currentMenu = menuwe;
    if (menuwe == 'call_logs') {
    } else {
      // getVoiceMails();
    }
  }

  Icon _getCdrIcon(CdrModel cdr) {
    // if (cdrs.incoming != null)
    //   cdrs.incoming!
    //       ? cdrs.connected!
    //       ? Icon(
    //     Icons.call_received_rounded,
    //     color: Colors.green,
    //   )
    //       : Icon(
    //     Icons.call_missed_rounded,
    //     color: Colors.red,
    //   )
    //       : cdrs.connected!
    //       ? Icon(
    //     Icons.call_made_rounded,
    //     color: Colors.lightGreen,
    //   )
    //       : const Icon(
    //     Icons.call_missed_outgoing_rounded,
    //     color: Colors.orange,
    //   ),

    if (cdr.incoming) {
      return cdr.connected
          ? const Icon(Icons.call_received_rounded, color: Colors.green)
          : const Icon(Icons.call_missed_rounded, color: Colors.red);
    } else {
      return cdr.connected
          ? const Icon(Icons.call_made_rounded, color: Colors.lightGreen)
          : const Icon(
            Icons.call_missed_outgoing_rounded,
            color: Colors.orange,
          );
    }
  }

  Icon _getCdrIconsAndCall(CallLogResponse Call) {
    // if (cdrs.src == SharedPrefs().getValue(Constants.EXTENSION_NUMBER))
    //   Icon(Icons.call_made_sharp, color: Colors.grey),
    //
    // if (cdrs.dst == SharedPrefs().getValue(Constants.EXTENSION_NUMBER) ||
    //     (cdrs.dst != SharedPrefs().getValue(Constants.EXTENSION_NUMBER) &&
    //         cdrs.src != SharedPrefs().getValue(Constants.EXTENSION_NUMBER)))
    //   Icon(Icons.call_received_sharp, color: Colors.grey),

    if (Call.src == SharedPrefs().getValue(Constants.EXTENSION_NUMBER)) {
      return Call.disposition != 'NO ANSWER'
          ? const Icon(Icons.call_received_rounded, color: Colors.green)
          : const Icon(Icons.call_missed_rounded, color: Colors.red);
    } else {
      return Call.disposition == 'ANSWERED'
          ? const Icon(Icons.call_made_rounded, color: Colors.lightGreen)
          : const Icon(
        Icons.call_missed_outgoing_rounded,
        color: Colors.orange,
      );
    }
  }

  Widget _getCdrTitle(CdrModel cdr) {
    return Text(
      cdr.displName.isEmpty
          ? cdr.remoteExt
          : "${cdr.displName} (${cdr.remoteExt})",
      style: Theme.of(context).textTheme.titleSmall,
    );
  }

  Widget? _getCdrSubTitle(CdrModel cdr) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          cdr.accUri,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        ),
        Wrap(
          spacing: 5,
          children: [
            Text(
              cdr.madeAtDate,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
            if (cdr.connected) Text("Duration: ${cdr.duration}"),
            if (cdr.statusCode != 0) Text("Status code: ${cdr.statusCode}"),
            if (cdr.hasVideo)
              const Icon(Icons.videocam_outlined, color: Colors.grey, size: 18),
          ],
        ),
      ],
    );
  }

  Widget _getCdrRowTrailing(
    CallLogHistory cdr,
    int index,
    LayoutProvider provider,
  ) {
    return PopupMenuButton<CdrAction>(
      onSelected: (CdrAction action) {
        // for (var i = 0; i < provider.mCallLogHistory.length; i++) {
        // }
        // _onCdrMenuAction(action, index);
        provider.deleteCallLog(cdr);
      },
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<CdrAction>>[
            const PopupMenuItem<CdrAction>(
              value: CdrAction.delete,
              child: Wrap(
                spacing: 5,
                children: [Icon(Icons.delete), Text("Delete")],
              ),
            ),
          ],
    );
  }

  void _onCdrMenuAction(CdrAction action, int index) {
    context.read<CdrsModel>().remove(index);
  }
}
