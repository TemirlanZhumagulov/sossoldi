import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api_service.dart';
import '../../database/kazfintracker_database.dart';
import '../../providers/chat_provider.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  late List<String> _messages = [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() async {
    List<String> messages = await KazFinTrackerDatabase.instance.getMessages();
    setState(() {
      _messages = messages;
    });
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      String message = _controller.text;
      try {
        String response = await _apiService.sendChatMessage(message);

        if (response.contains("http://www.kazfintracker.files/")) {
          try {
            String fileName = "report_${DateTime.now()}.xlsx";
            File downloadedFile = await _apiService.downloadFile(fileName);
            setState(() {
              _messages.add("Report downloaded successfully: ${downloadedFile.path}");
            });

          } catch (e) {
            setState(() {
              _messages.add("Failed to download report: $e");
            });
          }
        } else {
          setState(() {
            _messages.add("You: $message");
            _messages.add("Bot: $response");
          });
        }

        await KazFinTrackerDatabase.instance.saveMessage("You: $message");
        await KazFinTrackerDatabase.instance.saveMessage("Bot: $response");
        _controller.clear();
      } catch (e) {
        setState(() {
          _messages.add("Failed to send message: $e");
        });
        await KazFinTrackerDatabase.instance.saveMessage("Failed to send message: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ref.read(authenticationServiceProvider).isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == true) {
            return Scaffold(
              // appBar: AppBar(
              //   title: const Text("Context 1"),
              // ),
              body: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        bool isUserMessage = _messages[index].startsWith("You:");
                        return ListTile(
                          leading: Icon(isUserMessage ? Icons.person : Icons.assistant),
                          title: Text(
                            _messages[index],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              labelText: "Send a message",
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (value) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("You must be registered to use the chat."),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/register'),
                          child: const Text('Register'),
                        ),
                        const SizedBox(width: 20),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/login'),
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
