import 'dart:convert';

class BasedResponse<T> {
  T? data;
  String? message;
  String status;

  BasedResponse({this.data, this.message, required this.status});

  factory BasedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromDataJson,
  ) {
    return BasedResponse<T>(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: fromDataJson(json['data'] ?? {}),
    );
  }

  factory BasedResponse.fromJsonString(
      Map<String, dynamic> json,
      T Function(dynamic json) fromJsonT,
      ) {
    return BasedResponse<T>(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: fromJsonT(json['data']),
    );
  }

  Map<String, dynamic> toJson(
      dynamic Function(T value) toJsonT,
      ) {
    return {
      'status': status,
      'message': message,
      'data': toJsonT(data!),
    };
  }

  Map<String, dynamic> toMap() {
    return {'message': message, 'status': status};
  }

  factory BasedResponse.fromMap(Map<String, dynamic> map) {
    return BasedResponse<T>(message: map['message'], status: map['status']);
  }

  String toJsonn() => json.encode(toMap());

  factory BasedResponse.fromJsonn(String source) =>
      BasedResponse.fromMap(json.decode(source));

  BasedResponse<T> copyWith({T? data, String? message, String? status}) {
    return BasedResponse<T>(
      data: data ?? this.data,
      message: message ?? this.message,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'api_response(data: $data, message: $message, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BasedResponse<T> &&
        other.data == data &&
        other.message == message &&
        other.status == status;
  }

  @override
  int get hashCode {
    return data.hashCode ^ message.hashCode ^ status.hashCode;
  }
}
