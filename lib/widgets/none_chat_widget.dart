import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:gpt4client/widgets/create_chat_dialog.dart';

class NoneChatWidget extends StatelessWidget {
  final BeamerDelegate beamer;
  const NoneChatWidget({super.key, required this.beamer});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: const Text("Start a new Chat"),
        onPressed: () => startChat(context),
      ),
    );
  }

  startChat(BuildContext context) {
    showDialog(context: context, builder: (context) => Dialog(child: CreateChatDialog(beamer: beamer)),).then((value) => {
      Beamer.of(context).beamToNamed("/main/chats/${value.id}")
    });

  }
}
