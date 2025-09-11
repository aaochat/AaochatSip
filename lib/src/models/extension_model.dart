import 'package:callingproject/main.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/network_model.dart';

class Extension {
  String id;
  String userId;
  String extensionNumber;
  String sipUsername;
  String sipPassword;
  DateTime createdAt;
  DateTime updatedAt;
  SipServer? sipServer;

  Extension({
    required this.id,
    required this.userId,
    required this.extensionNumber,
    required this.sipUsername,
    required this.sipPassword,
    required this.createdAt,
    required this.updatedAt,
    required this.sipServer,
  });

  factory Extension.fromJson(Map<String, dynamic> json) {
    return Extension(
      id: json['_id'],
      userId: json['user_id'],
      extensionNumber: json['extension_number'],
      sipUsername: json['sip_username'],
      sipPassword: json['sip_password'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      sipServer: json["sip_server"] != null ? SipServer.fromJson(json["sip_server"]) : null,
    );
  }

  AccountModel toAccountModel() {
    AccountModel account = AccountModel();
    account.sipServer = sipServer!.host!;
    account.sipExtension = extensionNumber;
    account.sipPassword = sipPassword;
    account.expireTime = 350;
    account.port = sipServer!.port!;
    account.transport = sipServer!.protocol == "UDP" ? SipTransport.udp : SipTransport.tcp;
    account.ringTonePath = MyApp.getRingtonePath();
    return account;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': userId,
      "sip_server": sipServer!.toJson(),
      'extension_number': extensionNumber,
      'sip_username': sipUsername,
      'sip_password': sipPassword,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class SipServer {
  String? id;
  String? name;
  String? host;
  int? port;
  String? protocol;

  SipServer({this.id, this.name, this.host, this.port, this.protocol});

  factory SipServer.fromJson(Map<String, dynamic> json) => SipServer(
    id: json["_id"],
    name: json["name"],
    host: json["host"],
    port: json["port"],
    protocol: json["protocol"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "host": host,
    "port": port,
    "protocol": protocol,
  };
}