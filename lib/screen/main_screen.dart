import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:gpt4client/api/client_api.dart';
import 'package:gpt4client/data/chat.dart';
import 'package:gpt4client/locations/chat_location.dart';
import 'package:gpt4client/widgets/create_chat_dialog.dart';
import 'package:gpt4client/widgets/edit_chat_dialog.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rxdart/rxdart.dart';

class MainScreen extends StatelessWidget {
  final _beamerKey = GlobalKey<BeamerState>();


  MainScreen({Key? key}) : super(key: key);

  final BehaviorSubject<Chat?> _choosenChat = BehaviorSubject<Chat?>();
  final BehaviorSubject<List<Chat>> _chatList = BehaviorSubject<List<Chat>>();

  get choosenChatStream => _choosenChat.stream;
  get chatListStream => _chatList.stream;

  @override
  Widget build(BuildContext ctx) {
    if (!_chatList.hasValue) {
      refresh(ctx);
    }
    return Scaffold(
      appBar: AppBar(
          title: StreamBuilder<Chat?>(
              stream: choosenChatStream,
              builder: (context, snapshot) {
                return snapshot.data != null
                    ? Text("${snapshot.data!.name}:${snapshot.data!.model}")
                    : const Text('');
              }),
          centerTitle: true,
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Row(
                    children: [Icon(Icons.logout), Text("Logout")],
                  ),
                  onTap: () {
                    var box = Hive.box("login");
                    ClientAPI().authToken = "";
                    box.put("authToken", "");
                    Beamer.of(ctx).beamToNamed("/login");
                  },
                ),

              ],
            )
          ]),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Beamer(
          key: _beamerKey,
          routerDelegate: BeamerDelegate(
            initialPath: '/main/none',
            routeListener: (inf, delg) { refresh(ctx); adjustChoosen(inf);},
            locationBuilder: BeamerLocationBuilder(
              beamLocations: [
                NoneChatLocation(),
                ChatLocation(),
              ],
            ),
          ),
        ),
      ),
      drawer: StreamBuilder<List<Chat>>(
          stream: chatListStream,
          initialData: const [],
          builder: (context, snapshot) {
            return Drawer(
              child: ListView(
                children: [
                  ListTile(
                    title: ElevatedButton(
                        onPressed: () => createNewChat(ctx),
                        child: const Row(
                            children: [Icon(Icons.add), Text("New Chat")])),
                    trailing: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Icon(Icons.view_sidebar)),
                  ),
                  ...snapshot.data!.map((chat) {
                    return StreamBuilder<Chat?>(
                      stream: choosenChatStream,
                      builder: (context, chatSnap) {
                        return ListTile(
                          title: Text(chat.name),
                          onTap: () => chooseChat(chat),
                          tileColor:
                              chatSnap.data == chat ? Colors.blueAccent : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.settings),
                                onPressed: () => editChat(chat, context),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => deleteChat(chat.id, context),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            );
          }),
    );
  }

  deleteChat(int id, BuildContext ctx) {
    ClientAPI().deleteChat(id).then((value) {
      refresh(ctx);
      if (_choosenChat.hasValue && _choosenChat.value != null && id == _choosenChat.value!.id) {
        _choosenChat.add(null);
        _beamerKey.currentState?.routerDelegate.beamToNamed("/main/none");
      }
    });
  }

  refresh(BuildContext ctx) async {
    try {
      var list = await ClientAPI().getChatList();
      _chatList.add(list);
    } catch (ex) {
      Beamer.of(ctx).beamToNamed("/login");
    }
  }

  chooseChat(Chat chat) {
    _choosenChat.add(chat);
    _beamerKey.currentState?.routerDelegate
        .beamToNamed("/main/chats/${chat.id}");
  }

  createNewChat(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) =>
          Dialog(child: CreateChatDialog(beamer: Beamer.of(context))),
    ).then((value) {
      if(value != null) {
        _beamerKey.currentState?.routerDelegate.beamToNamed("/main/chats/${value.id}");
      }
    });
  }

  void adjustChoosen(RouteInformation inf) {
    if(inf.location!.contains("/main/chats")){
      var id = inf.location!.split("/").last;
      ClientAPI().getChat(int.parse(id)).then((value) => _choosenChat.add(value));
    }
  }

  editChat(Chat chat, BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) =>
          Dialog(child: EditChatDialog(chat:chat, beamer: Beamer.of(context))),
    ).then((value) {
      if(value != null
      && _choosenChat.hasValue
      && _choosenChat.value != null) {
        if(value.id == _choosenChat.value!.id) {
          _choosenChat.add(value);
          _beamerKey.currentState?.routerDelegate.beamToNamed(
              "/main/chats/${value.id}");
        }
      }
      refresh(context);
    });
  }
}
