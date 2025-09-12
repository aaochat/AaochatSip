import 'dart:convert';
import 'package:intl/intl.dart';
class VoiceMailLog {
  final String caller_id;
  final String file;
  final String date;
  final String path;
  VoiceMailLog({
    required this.caller_id,
    required this.file,
    required this.date,
    required this.path,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'caller_id': caller_id});
    result.addAll({'file': file});
    result.addAll({'date': date});
    result.addAll({'path': path});

    return result;
  }

  factory VoiceMailLog.fromMap(Map<String, dynamic> map) {
    return VoiceMailLog(
      caller_id: map['caller_id'] ?? '',
      file: map['file'] ?? '',
      date: map['date'] ?? '',
      path: map['path'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory VoiceMailLog.fromJson(String source) =>
      VoiceMailLog.fromMap(json.decode(source));

  String getVoiceMailFile() {
    return path;
  }

  String getFormattedDate() {
    DateTime voiceMailDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').parse(date, true).toLocal();
    return DateFormat('dd MMM yy hh:mm a').format(voiceMailDate);
  }
}
