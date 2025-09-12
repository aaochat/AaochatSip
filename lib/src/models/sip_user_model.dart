class SIPUser {
  String name;
  String extension;

  SIPUser({required this.name, required this.extension});

  factory SIPUser.fromJson(Map<String, dynamic> json) =>
      SIPUser(name: json["name"], extension: json["extension"]);

  Map<String, dynamic> toJson() => {"name": name, "extension": extension};
}
