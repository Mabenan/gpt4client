import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpt4client/api/client_api.dart';
import 'package:gpt4client/data/chat_entry.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChatView extends StatefulWidget {
  final int chatId;
  const ChatView({super.key, required this.chatId});

  @override
  ChatViewState createState() => ChatViewState();
}

class ChatViewState extends State<ChatView> {
  final TextEditingController _textEditingController = TextEditingController();
  Stream<String>? lastChatStream;
  String lastChatText = "";
  List<ChatEntry> chatMessages = [];
  bool dataLoaded = false;

  late final _focusNode = FocusNode(
    onKey: (FocusNode node, RawKeyEvent evt) {
      if (!evt.isShiftPressed && evt.logicalKey.keyLabel == 'Enter') {
        if (evt is RawKeyDownEvent) {
          _handleSubmittedMessage(_textEditingController.text);
        }
        return KeyEventResult.handled;
      }
      else {
        return KeyEventResult.ignored;
      }
    },
  );

  bool isdispose = false;

  void _handleSubmittedMessage(String message) {
    if (message.isNotEmpty) {
      _textEditingController.clear();
      setState(() {
        lastChatText = "";
        chatMessages.add(ChatEntry(
            id: 0,
            chatId: widget.chatId,
            role: 'user',
            content: message,
            datetime: DateTime.now()));
        lastChatStream = ClientAPI().generate(widget.chatId, message);
      });
      lastChatStream!.last.then((value) => refresh());
    }
  }

  @override
  void dispose() {
    isdispose = true;
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!dataLoaded) {
      refresh();
    }
    return Center(
      child: Column(
        children: [
          Flexible(
            flex: 9,
            fit: FlexFit.tight,
            child: ListView(
              reverse: true,
              children: [
                ...(lastChatStream != null
                    ? [
                        StreamBuilder<String>(
                          stream: lastChatStream!,
                          builder: (context, snapshot) {
                            lastChatText +=
                                snapshot.data != null ? snapshot.data! : "";
                            return ChatBubble(
                                message: lastChatText, isMe: false);
                          },
                        )
                      ]
                    : []),
                ...chatMessages.reversed.map((message) => ChatBubble(
                      message: message.content,
                      isMe: message.role == 'user',
                    )),
              ],
            ),
          ),
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      focusNode: _focusNode,
                      controller: _textEditingController,
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.none,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () =>
                        _handleSubmittedMessage(_textEditingController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void refresh() {
    ClientAPI().getChatEntryList(widget.chatId).then((value) {
      if (!isdispose) {
        setState(() {
          lastChatStream = null;
          dataLoaded = true;
          chatMessages = value;
        });
      }
    });
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: message != ""
            ? SelectableText(
                message,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                  fontSize: 16.0,
                ),
              )
            : LoadingAnimationWidget.waveDots(
                color: isMe ? Colors.white : Colors.black, size: 16),
      ),
    );
  }
}

class _PulsatingDot extends StatefulWidget {
  @override
  _PulsatingDotState createState() => _PulsatingDotState();
}

class _PulsatingDotState extends State<_PulsatingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
      child: Container(
        width: 8.0,
        height: 8.0,
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
