import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class chatbot extends StatefulWidget {
  const chatbot({super.key});

  @override
  State<chatbot> createState() => _chatbotState();
}

class _chatbotState extends State<chatbot> {
  late types.User _currentUser;
  final types.User _aiUser = const types.User(
    id: '2',
    firstName: "AI",
    imageUrl:
        "https://cdn-icons-png.flaticon.com/512/4712/4712035.png", // optional bot avatar
  );

  final List<types.Message> _messages = [];
  late GenerativeModel _geminiModel;

  final _uuid = const Uuid();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _initializeGemini();
  }

  void _initializeUser() {
    final user = FirebaseAuth.instance.currentUser;
    _currentUser = types.User(
      id: user?.uid ?? 'unknown',
      firstName: user?.displayName ?? 'Guest',
      imageUrl: user?.photoURL ??
          "https://cdn-icons-png.flaticon.com/512/1077/1077012.png", // default user avatar
    );
  }

  void _initializeGemini() {
    _geminiModel = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: dotenv.env['GEMINI_API_KEY']!,
    );
  }

  void _handleSendPressed(types.PartialText message) async {
    final userMessage = types.TextMessage(
      author: _currentUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: _uuid.v4(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, userMessage);
      _isTyping = true;
    });

    try {
      final response =
          await _geminiModel.generateContent([Content.text(message.text)]);

      final botMessage = types.TextMessage(
        author: _aiUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: _uuid.v4(),
        text: response.text ?? "Sorry, I couldn't process your request.",
      );

      setState(() {
        _messages.insert(0, botMessage);
        _isTyping = false;
      });
    } catch (e) {
      final errorMessage = types.TextMessage(
        author: _aiUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: _uuid.v4(),
        text: "An error occurred. Please try again.",
      );

      setState(() {
        _messages.insert(0, errorMessage);
        _isTyping = false;
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        Container(
          height: 160,
          width: double.infinity,
          color: const Color(0xFF2184FC).withOpacity(0.76),
          child: const Padding(
            padding: EdgeInsets.only(top: 60.0, left: 22),
            child: Text(
              "Mirsad's AI Assistant",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
          Padding(
            padding: const EdgeInsets.only(top: 120.0), // adjust as needed
            child: Chat(
              messages: _isTyping
                  ? [
                      types.TextMessage(
                        id: 'typing-indicator',
                        author: _aiUser,
                        createdAt: DateTime.now().millisecondsSinceEpoch,
                        text: "AI is typing...",
                        metadata: {'isTyping': true},
                      ),
                      ..._messages
                    ]
                  : _messages,
              onSendPressed: _handleSendPressed,
              user: _currentUser,
              showUserAvatars: true,
              theme: DefaultChatTheme(
                inputBackgroundColor: Colors.white,
                inputTextColor: Colors.black,
                primaryColor: const Color(0xFF2184FC),
                secondaryColor: const Color.fromARGB(255, 217, 211, 211),
                receivedMessageBodyTextStyle:
                    const TextStyle(color: Colors.black),
                sentMessageBodyTextStyle: const TextStyle(color: Colors.white),
                backgroundColor: Colors.grey[100]!,
                inputTextDecoration: InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(color: Color(0xFF2184FC)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(color: Color(0xFF2184FC)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide:
                        const BorderSide(color: Color(0xFF2184FC), width: 2.0),
                  ),
                ),
                typingIndicatorTheme: TypingIndicatorTheme(
                  animatedCirclesColor: Colors.grey,
                  animatedCircleSize: 5.0,
                  bubbleBorder: const BorderRadius.all(Radius.circular(12)),
                  bubbleColor: Colors.grey[300]!,
                  countAvatarColor: Colors.grey,
                  countTextColor: Colors.white,
                  multipleUserTextStyle: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}