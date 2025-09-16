import 'dart:convert';

import 'package:event_taxi/event_taxi.dart';

class CallAnalyticsUpdatedEvent extends Event {
  String recording_file;
  bool is_call_summary;

  CallAnalyticsUpdatedEvent({required this.recording_file, required this.is_call_summary});

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'recording_file': recording_file});
    result.addAll({'is_call_summary': is_call_summary});

    return result;
  }

  factory CallAnalyticsUpdatedEvent.fromMap(Map<String, dynamic> map) {
    return CallAnalyticsUpdatedEvent(
      recording_file: map['recording_file'] ?? '',
      is_call_summary: map['is_call_summary'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory CallAnalyticsUpdatedEvent.fromJson(String source) =>
      CallAnalyticsUpdatedEvent.fromMap(json.decode(source));
}
