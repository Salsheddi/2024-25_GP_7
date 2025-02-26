import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:mirsad/Auth/chatbot.dart';
import 'package:mirsad/Auth/Home.dart';
import 'package:mirsad/Auth/Profile.dart';

class AboutMirsadPage extends StatefulWidget {
  const AboutMirsadPage({Key? key}) : super(key: key);

  @override
  State<AboutMirsadPage> createState() => _AboutMirsadPageState();
}

class _AboutMirsadPageState extends State<AboutMirsadPage> {
  int _currentIndex = 1; // Default to Home tab
  final ScrollController _featureScrollController = ScrollController();

  // Feature Cards
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
      'title': 'Chatbot',
      'description': 'Get guidance through the app features and FAQs with our chatbot.',
    },
  ];

  @override
  void dispose() {
    _featureScrollController.dispose();
    super.dispose();
  }

  /// Scroll feature cards left/right
  void _scrollFeatures(double offset) {
    final double newOffset = (_featureScrollController.offset + offset).clamp(
      0.0,
      _featureScrollController.position.maxScrollExtent,
    );
    _featureScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.85;
    const Color headingColor = Color(0xFF2184FC);
    const Color backgroundColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: headingColor,
        automaticallyImplyLeading: true, // Enables back button
        iconTheme: const IconThemeData(color: Colors.white), // White back button
        title: const Text(
          'About Mirsad',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: backgroundColor,

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Image Section
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

            // "What Is Mirsad?" Card
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

            // Feature Cards
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
                        Image.asset(
                          cardData['icon']!,
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 12),
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

            // Arrows for Scrolling Features
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
            const SizedBox(height: 24),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color(0xFFF7F6F6),
        height: 70,
        color: headingColor.withOpacity(0.65),
        animationDuration: const Duration(milliseconds: 350),
        index: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Switches to the selected page
          });
        },
        items: const [
          Icon(Icons.smart_toy_outlined, size: 32, color: Colors.white), // Chatbot
          Icon(Icons.home, size: 32, color: Colors.white), // Home
          Icon(Icons.person, size: 32, color: Colors.white), // Profile
        ],
      ),
    );
  }
}

