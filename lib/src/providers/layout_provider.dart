import 'dart:convert';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:callingproject/src/Databased/calllog_history.dart';
import 'package:callingproject/src/api_response/api_response.dart';
import 'package:callingproject/src/models/call_model.dart';
import 'package:callingproject/src/repository/sip_repository.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/cdrs_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../api_response/call_log_response.dart';
import '../event/CallAnalyticsUpdatedEvent.dart';
import '../event/refresh_call_log_event.dart';
import '../models/voice_mail_log.dart';
import '../utils/Constants.dart';
import '../utils/shared_prefs.dart';

class LayoutProvider extends ChangeNotifier {
  String _currentScreen = 'dialpad';

  String get currentScreen => _currentScreen;

  String sideScreen = 'call-logs';
  String callId = '';
  EventTaxi eventBus = EventTaxiImpl.singleton();

  Map<String, String> allTelephoneMaster = <String, String>{};

  String _Callstatus = '';

  String get status => _Callstatus;

  final player = AudioPlayer();

  DateFormat format = DateFormat("MMM dd yyyy, hh:mm:ss a");

  bool showCallPage = false;

  connectToSocket(String sipServer) {
    String mBaseUrl = "http://" + sipServer + ":3000/";
    print('connecting to socket');
    IO.Socket socket = IO.io(
        mBaseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect()
            .enableReconnection()
            .build());
    socket.onConnect((_) {
      print('connected to socket');
    });
    socket.on('call:summary:updated', (data) {
      eventBus.fire(CallAnalyticsUpdatedEvent.fromMap(data));
    });
    socket.onError((error) => print(error));
    socket.onDisconnect((_) => print('disconnect'));
    socket.connect();
  }



  // List<CallLogHistory> filterTelephoneMaster(String search) {
  //   if (search.isEmpty) {
  //     return [];
  //   }
  //   return _box.values
  //       .where((mCallLogHistory) =>
  //   (mCallLogHistory.displName ?? '')
  //       .toLowerCase()
  //       .contains(search.toLowerCase()) ||
  //       (mCallLogHistory.id ?? '')
  //           .toLowerCase()
  //           .contains(search.toLowerCase()) ||
  //       (mCallLogHistory.home_no ?? '')
  //           .toLowerCase()
  //           .contains(search.toLowerCase()) ||
  //       (mCallLogHistory.mob_no ?? '')
  //           .toLowerCase()
  //           .contains(search.toLowerCase()))
  //       .toList();
  // }


  playRingtone() async {
    player.setVolume(1);
    await player.play(AssetSource('ringtone.mp3'));
  }

  stopRingtone() async {
    await player.stop();
  }

  // getCallDestinationName(CallLog? callLog) {
  //   String response = '${callLog?.dst}';
  //   if (callLog?.outbound_cnam != null && callLog!.outbound_cnam.isNotEmpty) {
  //     response += ' - ${callLog.outbound_cnam}';
  //   } else if (allTelephoneMaster[callLog?.dst ?? ''] != null) {
  //     response += ' - ${allTelephoneMaster[callLog?.dst ?? '']}';
  //   }
  //
  //   return response;
  // }

  /*Todo Api Calling Pending*/
  // getAllTelephoneMaster() async {
  //   var response = await TeamlocusRepository.getAllTelephoneMaster();
  //   if (response.status == 'ok') {
  //     for (var item in response.response!) {
  //       if (item.ext_no != null && item.ext_no!.isNotEmpty) {
  //         allTelephoneMaster[item.ext_no!] = item.user_name ?? '';
  //       }
  //     }
  //   }
  // }

  void UpdateCallToLogList(BuildContext context, CdrsModel calls,AppCallsModel callsModel) {
    if (!calls.isEmpty) {
      final callLog = CallLogHistory(
        myCallId: calls[0].myCallId,
        displName: callsModel[0].displName,
        remoteExt: callsModel[0].remoteExt,
        accUri: calls[0].accUri,
        duration: callsModel[0].durationStr,
        hasVideo: calls[0].hasVideo,
        incoming: calls[0].incoming,
        connected: calls[0].connected,
        statusCode: calls[0].statusCode,
        madeAtDate: calls[0].madeAtDate,
      );
      log("Call_Update_Log: ${callLog.toString()}");
    }
  }

  goToCallScreen() {
    _currentScreen = 'callscreen';
    notifyListeners();
  }


  clearCall(bool mIsUpdate) {
    eventBus.fire(RefreshCallLogEvent(isUpdate: mIsUpdate));
  }

  goToVoiceMails() {
    sideScreen = 'voice-mails';
    notifyListeners();
  }

  toggleCallPage() {
    showCallPage = !showCallPage;
    notifyListeners();
  }

  toggleIncomingCallPage() {
    showCallPage = true;
    notifyListeners();
  }

  goToDialPad() {
    _currentScreen = 'dialpad';
    notifyListeners();
  }

  goToCreateSupportTicket(String? callId) {
    this.callId = callId ?? '';
    sideScreen = 'create-support-ticket';
    notifyListeners();
  }

  goToCallLogs() {
    sideScreen = 'call-logs';
    callId = '';
    notifyListeners();
  }

  String getFormattedCallStatus(CallLogHistory cdr) {
    var mStatus = "";
    if (cdr.connected!) {
      mStatus = 'ANSWERED';
      return 'ANSWERED';
    } else if (cdr.incoming! && !cdr.connected!) {
      mStatus = 'MISSED CALL';
      return 'MISSED CALL';
    } else if (!cdr.connected!) {
      mStatus = 'NO ANSWER';
      return 'NO ANSWER';
    }
    return mStatus.toUpperCase();
  }


  String getFormattedCallStatusName(CallLogResponse cdr) {
    if (cdr.disposition == 'ANSWERED') {
      return 'ANSWERED';
    } else if (jsonDecode(SharedPrefs().getValue(Constants.EXTENSION_NUMBER)).toString().contains(cdr.dst) && cdr.disposition == 'NO ANSWER') {
      return 'MISSED CALL';
    }
    return cdr.disposition.toUpperCase();
  }

  Color getCallLogColor(CallLogResponse cdr) {
    if (cdr.disposition == 'ANSWERED') {
      return Colors.green.shade900;
    } else {
      return Colors.red.shade900;
    }
  }

  String convertDateFormat(String dateString) {
    try {
      // Step 1: Parse ISO date string into DateTime object
      DateTime utcDateTime = DateTime.parse(dateString).toUtc();
      DateTime dateTime = DateTime.parse(dateString).toLocal();

      // Step 2: Desired output format
      String desiredFormat = "d-M-yyyy, hh:mm a";
      DateFormat outputFormat = DateFormat(desiredFormat);

      return outputFormat.format(utcDateTime);
    } catch (e) {
      print('Error during date format conversion: $e');
      return dateString; // fallback
    }
  }

  String convertOnlyDateFormat(String dateString) {
    try {
      // Step 1: Parse ISO date string into DateTime object
      DateTime utcDateTime = DateTime.parse(dateString).toUtc();
      DateTime dateTime = DateTime.parse(dateString).toLocal();

      // Step 2: Desired output format
      String desiredFormat = "d-M-yyyy";
      DateFormat outputFormat = DateFormat(desiredFormat);

      return outputFormat.format(utcDateTime);
    } catch (e) {
      print('Error during date format conversion: $e');
      return dateString; // fallback
    }
  }

  String convertTimeFormat(String dateString) {
    try {
      // Step 1: Parse ISO date string into DateTime object
      DateTime utcDateTime = DateTime.parse(dateString).toUtc();
      DateTime dateTime = DateTime.parse(dateString).toLocal();

      // Step 2: Desired output format
      String desiredFormat = "hh:mm a";
      DateFormat outputFormat = DateFormat(desiredFormat);

      return outputFormat.format(utcDateTime);
    } catch (e) {
      print('Error during date format conversion: $e');
      return dateString; // fallback
    }
  }


  bool _loading = false;
  bool _hasMore = true;
  String _error = "";
  int _page = 1;
  List<CallLogResponse> _logList = [];
  static const _pageSize = 50;

  bool get isLoading => _loading;

  bool get hasMore => _hasMore;

  String get error => _error;

  List<CallLogResponse> get logList => _logList;

  Future<void> getCallLogs(String sipServerHost, String mExtensionId,
      {bool isFirstTime = false}) async {
    if (_loading) {
      return;
    }

    if (isFirstTime) {
      _page = 1;
      _logList.clear();
      _hasMore = true;
      _error = "";
    }

    if (!_hasMore) {
      return;
    }

    _loading = true;
    _error = "";
    

    try {
      ApiResponse<List<CallLogResponse>> response = await SipRepository.getCallLogs(sipServerHost, mExtensionId, {
        'page': _page,
        'limit': _pageSize,
      });

      if (response.status == "success" && response.data != null) {
        final newItems = response.data ?? [];
        _logList.addAll(newItems);
        _page++;
        _hasMore = false;
      } else {
        _error = response.message ?? "Something went wrong";
      }
    } catch (e) {
      // Handle any other unexpected errors
      _error = "An unexpected error occurred: $e";
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// optional: pull-to-refresh
  Future<void> refreshLogs(String sipServerHost, String mExtensionId) async {
    _page = 1;
    _logList.clear();
    await getCallLogs(sipServerHost, mExtensionId);
  }

  /*Pagination Api calling */
  Future<String> getNewCallLogs(String sipServerHost, String mExtensionId) async {
    try {
      ApiResponse<List<CallLogResponse>> response = await SipRepository.getCallLogs(sipServerHost, mExtensionId, {
        'page': 1,
        'limit': _pageSize,
      });

      if (response.status == "success" && response.data != null) {
        // check if any unique id is not present in the list
        bool unAddedRecords = false;
        // _logList = response.data!;
        for (var callLog in response.data ?? []) {
          if (!_logList
              .map((e) => e.uniqueid)
              .toList()
              .contains(callLog.uniqueid)) {
            unAddedRecords = true;
          }
        }

        if (!unAddedRecords) {
          print('no new records');
          return "";
        }

        for (var callLog in response.data ?? []) {
          if (!_logList
              .map((e) => e.uniqueid)
              .toList()
              .contains(callLog.uniqueid)) {
            _logList.insert(0, callLog);
          }
        }
        notifyListeners(); // update UI silently
      } else {
        _error = response.message ?? "Something went wrong";
      }
      return "success";
    } catch (e) {
      return "error";
    }
  }

  List<VoiceMailLog> _voicemailList = [];

  List<VoiceMailLog> get voiceMailList => _voicemailList;

  Future<void> getVoiceMailList(BuildContext context) async {
    if (_loading)
      return;
    _loading = true;

    try {
      final selectedAccountId = context
          .read<AccountsModel>()
          .selAccountId;
      final selectedAccount = context
          .read<AccountsModel>()
          .accounts
          .firstWhere(
              (element) => element.myAccId == selectedAccountId);

      ApiResponse<List<VoiceMailLog>> response =
      await SipRepository.getVoiceMailList(
        selectedAccount.sipServer,
        selectedAccount.sipExtension,

      );
      if (response.status == "success" && response.data != null) {
        final newItems = response.data ?? [];
        _voicemailList = newItems;
      }
      _loading = false;
    } catch (e) {
      print(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  getCallDestinationName(CallLogResponse? callLog) {
    String response = '${callLog?.dst}';
    if (callLog?.outboundCnam != null && callLog!.outboundCnam.isNotEmpty) {
      response += ' - ${callLog.outboundCnam}';
    } else if (allTelephoneMaster[callLog?.dst ?? ''] != null) {
      response += ' - ${allTelephoneMaster[callLog?.dst ?? '']}';
    }

    return response;
  }
}
