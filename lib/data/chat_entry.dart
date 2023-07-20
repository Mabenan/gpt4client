import 'dart:convert';

class ChatEntry {
  final int id;
  final int chatId;
  final String role;
  final String content;
  final DateTime datetime;

  ChatEntry({required this.id, required this.chatId, required this.role, required this.content, required this.datetime});

  factory ChatEntry.fromJson(Map<String, dynamic> json) {
    return ChatEntry(
      id: json['id'],
      chatId: json['chat_id'],
      role: json['role'],
      content: json['content'],
      datetime: DateTime.parse(json['datetime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'role': role,
      'content': content,
      'datetime': datetime.toIso8601String(),
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  static ChatEntry fromJsonString(String jsonString) {
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return ChatEntry.fromJson(jsonMap);
  }
}
