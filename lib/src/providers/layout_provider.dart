import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:callingproject/src/Databased/calllog_history.dart';
import 'package:callingproject/src/models/call_model.dart';
import 'package:dio/dio.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:siprix_voip_sdk/cdrs_model.dart';

import '../Repository/api_calling_repository.dart';
import '../api_response/call_log_response.dart';
import '../event/refresh_call_log_event.dart';
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

  final Box<CallLogHistory> _box = Hive.box<CallLogHistory>(
    Constants.TBL_CALLLOG,
  );
  DateFormat format = DateFormat("MMM dd yyyy, hh:mm:ss a");

  List<CallLogHistory> get mCallLogHistory =>
      _box.values.toList().reversed.toList();

  Future<void> UpdateCallLog(CallLogHistory callLog) async {
    final box = Hive.box<CallLogHistory>(Constants.TBL_CALLLOG);
    try {
      // Parse to DateTime
      DateTime parsedDate = format.parse(callLog.madeAtDate!);
      // Use millisecondsSinceEpoch as key
      String key = (parsedDate.millisecondsSinceEpoch.toString());
      // Save to Hive (add or update)
      await box.put(key, callLog);
      notifyListeners();

      print('Record added or updated at $key');
    } catch (e) {
      print('Failed to parse date or save record: $e');
    }
  }

  Future<void> Updateduration(String mDuration) async {
    if (_box.isNotEmpty) {
      final lastRecord = _box.values.last;
      DateTime parsedDate = format.parse(lastRecord.madeAtDate!);
      String key = (parsedDate.millisecondsSinceEpoch.toString());
      lastRecord.duration = mDuration;
      _box.put(key, lastRecord);
      notifyListeners();
    }
  }

  List<CallLogHistory> getSuggestions(String pattern) {
    return _box.values
        .where((log) => log.displName!.contains(pattern))
        .toList();
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

  Future<void> deleteCallLog(CallLogHistory cdr) async {
    final keyToDelete = _box.keys.firstWhere(
      (key) => _box.get(key)?.madeAtDate == cdr.madeAtDate,
      orElse: () => null,
    );

    if (keyToDelete != null) {
      _box.delete(keyToDelete);
      print("Record with id ${cdr.madeAtDate} deleted.");
    } else {
      print("Record not found.");
    }
    notifyListeners();
  }

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
      UpdateCallLog(callLog);
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
    } else if (cdr.dst == SharedPrefs().getValue(Constants.EXTENSION_NUMBER) && cdr.disposition == 'NO ANSWER') {
      return 'MISSED CALL';
    }

    return cdr.disposition.toUpperCase();
  }

  Color getCallLogColor(CallLogResponse cdr) {
    if (cdr.disposition == 'ANSWERED') {
      return Colors.green;
    } else {
      return Colors.red;
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

  Future<void> ApiCalling(BuildContext context, {bool isFirstTime = false}) async {
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
      var response = await ApiCallingRepo.GetLogListRequest(context, {
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
    } on DioException catch (dioError) {
      // Handle Dio-specific errors
      if (dioError.response!.statusCode == 400) {
        _error = dioError.response?.data["message"];
      } else if (dioError.type == DioExceptionType.receiveTimeout) {
        _error = "Receive timeout. Try again later.";
      } else if (dioError.type == DioExceptionType.badResponse) {
        _error = "Bad response: ${dioError.response?.statusCode}";
      } else if (dioError.type == DioExceptionType.connectionError) {
        _error = "Connection error. Please try again.";
      } else {
        _error = "Unexpected error occurred: ${dioError.message}";
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
  Future<void> refreshLogs(BuildContext context) async {
    _page = 1;
    _logList.clear();
    _hasMore = true;
    await ApiCalling(context);
  }

  /*Pagination Api calling */
  Future<String> refreshApiCalling(BuildContext context) async {
    try {
      final response = await ApiCallingRepo.GetLogListRequest(context, {
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

  void EventBusforUpdateCallLog(bool isUpdate) {
    eventBus.fire(RefreshCallLogEvent(isUpdate: isUpdate));
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
