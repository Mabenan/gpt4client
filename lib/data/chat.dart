import 'dart:convert';


class Chat {
  final int id;
  final int userId;
  final String name;
  String model;
  ModelSettings properties;

  Chat({required this.id, required this.userId, required this.name, required this.model, required this.properties});

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      model: json['model'],
      properties: ModelSettings.fromJson(jsonDecode(json["properties"]))
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'model': model,
      'properties': properties.toJson()
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  static Chat fromJsonString(String jsonString) {
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return Chat.fromJson(jsonMap);
  }
}
class ModelSettings {
  double temp;
  int topK;
  double topP;
  double repeatPenalty;
  int repeatLastN;
  int nBatch;
  int nPredict;

  ModelSettings({
    required this.temp,
    required this.topK,
    required this.topP,
    required this.repeatPenalty,
    required this.repeatLastN,
    required this.nBatch,
    required this.nPredict,
  });

  factory ModelSettings.fromJson(Map<String, dynamic> json) {
    return ModelSettings(
      temp: json['temp'],
      topK: json['top_k'],
      topP: json['top_p'],
      repeatPenalty: json['repeat_penalty'],
      repeatLastN: json['repeat_last_n'],
      nBatch: json['n_batch'],
      nPredict: json['n_predict'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temp': temp,
      'top_k': topK,
      'top_p': topP,
      'repeat_penalty': repeatPenalty,
      'repeat_last_n': repeatLastN,
      'n_batch': nBatch,
      'n_predict': nPredict,
    };
  }
}
