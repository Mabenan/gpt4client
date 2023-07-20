import 'dart:async';
import 'dart:convert';
import 'package:gpt4client/data/chat.dart';
import 'package:gpt4client/data/chat_entry.dart';
import 'package:gpt4client/data/model.dart';
import 'package:http/http.dart' as http;

class ClientAPI {
  static final ClientAPI _instance = ClientAPI._internal();

  factory ClientAPI() => _instance;

  ClientAPI._internal();

  String baseURL = "";
  String authToken = "";

  init(String baseURL) {
    this.baseURL = baseURL;
  }

  bool hasToken(){
    return authToken != "";
  }

  Future<Map<String, dynamic>> registerUser(
      String username, String password) async {
    checkBaseURL();
    final url = Uri.parse('$baseURL/register');
    final body = jsonEncode({'username': username, 'password': password});
    final response = await http.post(url, body: body);
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    checkBaseURL();
    final url = Uri.parse('$baseURL/login');
    final basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    final response = await http.post(url,
        headers: {'Authorization': basicAuth});
    if(response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('token')) {
        authToken = jsonResponse['token'];
      }
      return jsonResponse;
    }else{
      throw Exception("login failed: ${response.statusCode}");
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    checkBaseURL();
    final url = Uri.parse('$baseURL/me');
    final response =
        await http.get(url, headers: {'x-access-tokens': authToken});
    return jsonDecode(response.body);
  }

  Future<Chat> getChat(int chatId) async {
    checkBaseURL();
    final url = Uri.parse('$baseURL/chat/$chatId');
    final response =
        await http.get(url, headers: {'x-access-tokens': authToken});
    final jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 403) {
      throw Exception('Unauthorized');
    }
    return Chat.fromJson(jsonResponse);
  }

  Future<String> deleteChat(int chatId) async {
    checkBaseURL();
    final url = Uri.parse('$baseURL/chat/$chatId');
    final response =
        await http.delete(url, headers: {'x-access-tokens': authToken});
    if (response.statusCode == 403) {
      throw Exception('Unauthorized');
    }
    return response.body;
  }

  Future<List<Chat>> getChatList() async {
    checkBaseURL();
    final url = Uri.parse('$baseURL/chat/list');
    final response =
        await http.get(url, headers: {'x-access-tokens': authToken});
    final jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 403) {
      throw Exception('Unauthorized');
    }
    List<Chat> chatList = [];
    for (var chatJson in jsonResponse) {
      chatList.add(Chat.fromJson(chatJson));
    }
    return chatList;
  }

  Future<Chat> updateChat(int chatId, Chat chat) async {
    final url = Uri.parse('$baseURL/chat/$chatId');
    final requestBody = jsonEncode(chat.toJson());

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json', 'x-access-tokens': authToken},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return Chat.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to update chat: ${response.statusCode}');
    }
  }

  Future<List<ChatEntry>> getChatEntryList(int chatId) async {
    checkBaseURL();
    final url = Uri.parse('$baseURL/chat/$chatId/entry/list');
    final response =
        await http.get(url, headers: {'x-access-tokens': authToken});
    final jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 403) {
      throw Exception('Unauthorized');
    }
    List<ChatEntry> entryList = [];
    for (var entryJson in jsonResponse) {
      entryList.add(ChatEntry.fromJson(entryJson));
    }
    return entryList;
  }
  Future<Chat> createChat(Chat chat) async {
    checkBaseURL();
    final url = Uri.parse('$baseURL/chat');
    final encodedBody = jsonEncode(chat.toJson());

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'x-access-tokens': authToken},
      body: encodedBody,
    );
    if (response.statusCode == 403) {
      throw Exception('Unauthorized');
    }
    final jsonResponse = jsonDecode(response.body);
    return Chat.fromJson(jsonResponse);
  }
  Future<List<Model>> fetchModelList() async {
    checkBaseURL();
    final url = Uri.parse('$baseURL/gpt/model/list');
    final response =
        await http.get(url, headers: {'x-access-tokens': authToken});

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      List<Model> modelList = [];
      for (var modelJson in jsonResponse) {
        modelList.add(Model.fromJson(modelJson));
      }
      return modelList;
    } else {
      throw Exception('Failed to fetch model list: ${response.statusCode}');
    }
  }

  Stream<String> generate(int chatId, String prompt, {int limit = 0, int max_token = 200}) {
    final url = Uri.parse('$baseURL/gpt/chat/$chatId');
    final streamController = StreamController<String>();

    final requestBody = {'prompt': prompt, 'limit': limit, 'max_token': max_token};
    final encodedBody = jsonEncode(requestBody);

    var request = http.StreamedRequest('GET', url);
    request.headers['x-access-tokens'] = authToken;
    request.headers['content-type'] = 'application/json';
    request.sink.add(utf8.encode(encodedBody));
    unawaited(request.sink.close());

    return streamController.stream.asBroadcastStream(onListen: (subscription) {
      request.send().then((response) {
        if (response.statusCode == 200) {
          final responseStream = response.stream.transform(utf8.decoder);
          responseStream.listen((data) {
            streamController.add(data);
          }, onDone: () {
            streamController.close();
          }, onError: (error) {
            streamController.addError(error);
          });
        } else {
          streamController
              .addError('Failed to fetch chat stream: ${response.statusCode}');
        }
      }).catchError((error) {
        streamController.addError('Failed to fetch chat stream: $error');
      });
    });
  }

  void checkBaseURL() {
    if(baseURL == ""){
      throw Exception("no base URL");
    }
  }
}
