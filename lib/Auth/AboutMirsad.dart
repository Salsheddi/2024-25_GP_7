import 'dart:math';
import 'dart:ui'; // For ImageFilter.blur
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:mirsad/Auth/chatbot.dart';
import 'package:mirsad/Auth/Home.dart';
import 'package:mirsad/Auth/Profile.dart';
import 'package:mirsad/Auth/AboutMirsad.dart';

void main() {
  runApp(const AboutMirsad());
}

/// Root widget
class AboutMirsad extends StatelessWidget {
  const AboutMirsad({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mirsad Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AboutMirsadPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// About Mirsad Page (Stateful) with embedded quiz pop-up and bottom navigation bar.
class AboutMirsadPage extends StatefulWidget {
  const AboutMirsadPage({Key? key}) : super(key: key);

  @override
  State<AboutMirsadPage> createState() => _AboutMirsadPageState();
}

class _AboutMirsadPageState extends State<AboutMirsadPage> {
  // Controls whether the quiz pop-up is shown.
  bool _isQuizOpen = false;
  bool _isNavBarVisible = true;

  // List of feature card data.
  final List<Map<String, String>> featureCards = [
    {
      'icon': 'img/detectIcon.png',
      'title': 'Mirsad Fraud Detector',
      'description': 'A fraud detector helps you identify spam messages.',
    },
    {
      'icon': 'img/reportingIcon.png',
      'title': 'Fraud Messages Reporting',
      'description': 'You can report any spam message you receive to help spread awareness.',
    },
    {
      'icon': 'img/awarenessIcon.png',
      'title': 'Recent scams',
      'description': 'Be updated with the latest scams reported by other users.',
    },
    {
      'icon': 'img/reportIcon.png',
      'title': 'Fraud Insights',
      'description': 'Get a detailed analysis of the fraud messages you detected OR reported.',
    },
    {
      'icon': 'img/chatbotIcon.png',
      'title': 'chatbot',
      'description': 'Get guidance through the app features, and frequently asked questions with our chatbot.',
    },
  ];

  // Scroll controller for the horizontal feature list.
  final ScrollController _featureScrollController = ScrollController();

  // Quiz logic.
  bool _hasAnswered = false;
  bool _isCorrect = false;
  final List<Map<String, String>> _messages = [
    {
      'text': 'Your account has been locked. Please verify details at this link: bit.ly/fakeurl',
      'classification': 'Fraud',
    },
    {
      'text': 'Congratulations! You have won a free cruise. Click here to claim.',
      'classification': 'Fraud',
    },
    {
      'text': 'Reminder: Your dentist appointment is tomorrow at 3 PM. See you soon!',
      'classification': 'Legitimate',
    },
    {
      'text': 'Get 50% off on your next purchase using code SAVE50.',
      'classification': 'Legitimate',
    },
    {
      'text': 'Important: We detected suspicious activity on your credit card. Contact us immediately.',
      'classification': 'Fraud',
    },
    {
      'text': 'Your package has been shipped. Track it here: shipping.com/track',
      'classification': 'Legitimate',
    },
  ];
  late Map<String, String> _currentMessage;

  @override
  void initState() {
    super.initState();
    _pickRandomMessage();
  }

  @override
  void dispose() {
    _featureScrollController.dispose();
    super.dispose();
  }

  /// Pick a random message for the quiz.
  void _pickRandomMessage() {
    final randomIndex = Random().nextInt(_messages.length);
    _currentMessage = _messages[randomIndex];
    _hasAnswered = false;
    _isCorrect = false;
  }

  /// Scroll the feature cards left/right by a fixed offset.
  void _scrollFeatures(double offset) {
    final double newOffset =
        (_featureScrollController.offset + offset).clamp(
      0.0,
      _featureScrollController.position.maxScrollExtent,
    );
    _featureScrollController.animateTo(newOffset,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  /// Open the quiz pop-up.
  void _openQuiz() {
    setState(() {
      _pickRandomMessage();
      _isQuizOpen = true;
    });
  }

  /// Close the quiz pop-up.
  void _closeQuiz() {
    setState(() {
      _isQuizOpen = false;
    });
  }

  /// Check the user’s answer.
  void _checkAnswer(String userChoice) {
    setState(() {
      _hasAnswered = true;
      _isCorrect = (userChoice == _currentMessage['classification']);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Colors used in this design.
    const Color headingColor = Color(0xFF2184FC);
    const Color backgroundColor = Colors.white;
    const Color lightBackground = Color(0xFFEAF6FF);
    final double cardWidth = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: headingColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About Mirsad',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Main "About Mirsad" content.
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top area: only the image with a plain background.
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: backgroundColor,
                    child: Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Image.asset(
                            'img/Mirsad2.png',
                            height: 100,
                  width: 100, 
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  // "What Is Mirsad?" card.
                  Container(
                    width: cardWidth,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'What Is Mirsad?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: headingColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Mirsad is an application that helps you identify and classify messages to see if they are fraudulent or legitimate. It aims to raise awareness and keep you safe from scams.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Horizontal feature cards.
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _featureScrollController,
                    child: Row(
                      children: featureCards.map((cardData) {
                        return Container(
                          width: cardWidth,
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon from assets.
                              Image.asset(
                                cardData['icon']!,
                                width: 40,
                                height: 40,
                              ),
                              const SizedBox(width: 12),
                              // Title and description.
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cardData['title']!,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: headingColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      cardData['description']!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Arrow indicators under the feature cards.
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 30, color: Colors.grey),
                        onPressed: () => _scrollFeatures(-cardWidth),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 30, color: Colors.grey),
                        onPressed: () => _scrollFeatures(cardWidth),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // "Let's Play A Game!" button.
                  GestureDetector(
                    onTap: _openQuiz,
                    child: Container(
                      width: 180,
                      height: 100,
                      decoration: BoxDecoration(
                        color: headingColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Transform.rotate(
                          angle: -0.1,
                          child: const Text(
                            "Let's\nPlay A Game!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Quiz pop-up with blurred background.
          if (_isQuizOpen) ...[
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _hasAnswered ? _buildResultPopup() : _buildQuestionPopup(),
                ),
              ),
            ),
          ],
        ],
      ),
      // Bottom navigation bar.
      bottomNavigationBar: Visibility(
        visible: _isNavBarVisible,
        child: CurvedNavigationBar(
          backgroundColor: const Color(0xFFF7F6F6),
          height: 70,
          color: const Color(0xFF2184FC).withOpacity(0.65),
          animationDuration: const Duration(milliseconds: 350),
          index: 1,
          items: const [
            Icon(Icons.smart_toy_outlined, size: 32, color: Colors.white),
            Icon(Icons.home, size: 32, color: Colors.white),
            Icon(Icons.person, size: 32, color: Colors.white),
          ],
          onTap: (index) {
            // Navigate to the appropriate page based on the selected icon.
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const chatbot()),
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Profile()),
              );
            }
          },
        ),
      ),
    );
  }

  /// Builds the question portion of the quiz pop-up.
  Widget _buildQuestionPopup() {
    return Container(
      key: const ValueKey('questionPopup'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "X" button to close quiz.
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: _closeQuiz,
              child: const Icon(
                Icons.close,
                color: Colors.grey,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Icon(
            Icons.lightbulb_outline,
            color: Colors.amber,
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'Is This Message Fraud or Legitimate?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _currentMessage['text']!,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Answer buttons.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _checkAnswer('Fraud'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6F91),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Fraud',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => _checkAnswer('Legitimate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Legitimate',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the result portion of the quiz pop-up.
  Widget _buildResultPopup() {
    final String title = _isCorrect ? 'Correct Answer!' : 'Wrong Answer!';
    final String feedback = _isCorrect
        ? 'Great job! You clearly know how to spot suspicious messages.\nKeep using Mirsad to stay one step ahead of scammers.'
        : 'It looks like you might need some help identifying fraudulent messages.\nKeep practicing with Mirsad to protect yourself and others.';
    return Container(
      key: const ValueKey('resultPopup'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "X" button to close quiz.
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: _closeQuiz,
              child: const Icon(
                Icons.close,
                color: Colors.grey,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Icon(
            Icons.lightbulb_outline,
            color: Colors.amber,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            feedback,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

