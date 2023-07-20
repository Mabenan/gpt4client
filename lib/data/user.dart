import 'dart:convert';

class User {
  final int id;
  final int publicId;
  final String name;
  final String password;
  final bool admin;

  User({required this.id, required this.publicId, required this.name, required this.password, required this.admin});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      publicId: json['publicId'],
      name: json['name'],
      password: json['password'],
      admin: json['admin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'publicId': publicId,
      'name': name,
      'password': password,
      'admin': admin,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  static User fromJsonString(String jsonString) {
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return User.fromJson(jsonMap);
  }
}
