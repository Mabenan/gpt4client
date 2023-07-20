

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:gpt4client/widgets/chat_view.dart';
import 'package:gpt4client/widgets/none_chat_widget.dart';

class ChatLocation extends BeamLocation<BeamState>{
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(child: ChatView(chatId: int.parse(state.pathParameters['chatId']!),), title: "Chat", key: ValueKey('chat-${state.pathParameters['chatId']}'))
    ];
  }

  @override
  List<Pattern> get pathPatterns => ["/main/chats/:chatId"];


}

class NoneChatLocation extends BeamLocation<BeamState>{
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(child: NoneChatWidget(beamer: Beamer.of(context)), title: "Chat", key: const ValueKey('chat-none'))
    ];
  }

  @override
  List<Pattern> get pathPatterns => ["/main/none"];

}