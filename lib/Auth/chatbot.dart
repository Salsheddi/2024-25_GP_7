import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class chatbot extends StatefulWidget {
  const chatbot({super.key});

  @override
  State<chatbot> createState() => _chatbotState();
}

class _chatbotState extends State<chatbot> {
  late ChatUser _currentUser;
  final ChatUser _geminiChatUser = ChatUser(id: '2', firstName: "AI", lastName: "Assistant");

  List<ChatMessage> _messages = <ChatMessage>[];
  List<ChatUser> _typingUsers = <ChatUser>[];

  late GenerativeModel _geminiModel;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _initializeGemini();
  }

  void _initializeUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUser = ChatUser(id: user.uid, firstName: user.displayName ?? "User");
    } else {
      _currentUser = ChatUser(id: "unknown", firstName: "Guest");
    }
  }

  void _initializeGemini() {
    _geminiModel = GenerativeModel(
      model: 'gemini-2.0-flash',  // ✅ Correct model name
      apiKey: dotenv.env['GEMINI_API_KEY']!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
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
            padding: const EdgeInsets.only(top: 160.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Color(0xFFF7F6F6),
              ),
              height: double.infinity,
              width: double.infinity,
              child: DashChat(
  currentUser: _currentUser,
  typingUsers: _typingUsers,
  messageOptions: const MessageOptions(
    currentUserContainerColor: Color.fromRGBO(33, 132, 252, 0.76),
    containerColor: Color.fromARGB(255, 217, 211, 211),
    textColor: Color.fromARGB(255, 0, 0, 0),
  ),
  inputOptions: InputOptions(
    inputDecoration: InputDecoration(
      hintText: "Type a message...",
      hintStyle: TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,  // Background color
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20), // Rounded corners
        borderSide: BorderSide(color: Colors.blue, width: 2), // Border color & width
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.blueAccent, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
    ),
    inputToolbarMargin: EdgeInsets.all(10), // Adds spacing around the input field
    inputToolbarPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Padding inside input field
  ),
  onSend: (ChatMessage m) {
    getChatResponse(m);
  },
  messages: _messages,
)
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _typingUsers.add(_geminiChatUser);
    });

    try {
      final response = await _geminiModel.generateContent(
        [Content.text(m.text)],
      );

      if (response.text != null) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              user: _geminiChatUser,
              createdAt: DateTime.now(),
              text: response.text!,
            ),
          );
        });
      } else {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              user: _geminiChatUser,
              createdAt: DateTime.now(),
              text: "Sorry, I couldn't process your request.",
            ),
          );
        });
      }
    } catch (e) {
      debugPrint("Gemini API Error: $e");
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            user: _geminiChatUser,
            createdAt: DateTime.now(),
            text: "An error occurred. Please try again.",
          ),
        );
      });
    }

    setState(() {
      _typingUsers.remove(_geminiChatUser);
    });
  }
}
