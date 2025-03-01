import 'package:flutter/material.dart'; 
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:mirsad/Auth/chatbot.dart';
import 'package:mirsad/Auth/Profile.dart';
import 'package:mirsad/Auth/home.dart';

class AboutMirsadPage extends StatefulWidget {
  const AboutMirsadPage({Key? key}) : super(key: key);

  @override
  State<AboutMirsadPage> createState() => _AboutMirsadPageState();
}

class _AboutMirsadPageState extends State<AboutMirsadPage> {
  // This variable tracks the selected persistent tab:
  // null means no persistent tab has been selected and the default (About) view is shown.
  int? _selectedPersistentIndex;

  // Scroll controller for the feature cards.
  final ScrollController _featureScrollController = ScrollController();

  /// Scroll feature cards left/right.
  void _scrollFeatures(double offset) {
    final double newOffset = (_featureScrollController.offset + offset)
        .clamp(0.0, _featureScrollController.position.maxScrollExtent);
    _featureScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Returns the About Mirsad content.
  Widget _aboutContent() {
    const Color headingColor = Color(0xFF2184FC);
    const Color backgroundColor = Colors.white;
    // Fixed width for the cards.
    const double cardWidth = 350;

    // Feature cards data.
    final List<Map<String, String>> featureCards = [
      {
        'icon': 'img/detectIcon.png',
        'title': 'Mirsad Fraud Detector',
        'description': 'A fraud detector helps you identify spam messages.',
      },
      {
        'icon': 'img/reportingIcon.png',
        'title': 'Fraud Messages Reporting',
        'description':
            'You can report any spam message you receive to help spread awareness.',
      },
      {
        'icon': 'img/awarenessIcon.png',
        'title': 'Recent scams',
        'description':
            'Be updated with the latest scams reported by other users.',
      },
      {
        'icon': 'img/reportIcon.png',
        'title': 'Fraud Insights',
        'description':
            'Get a detailed analysis of the fraud messages you detected OR reported.',
      },
      {
        'icon': 'img/chatbotIcon.png',
        'title': 'Chatbot',
        'description':
            'Get guidance through the app features and FAQs with our chatbot.',
      },
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // "What Is Mirsad?" Card.
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
          // Feature Cards (Horizontal scroll).
          SingleChildScrollView(
            controller: _featureScrollController,
            scrollDirection: Axis.horizontal,
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
          // Navigation Buttons under the cards.
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left,
                    size: 30, color: Colors.grey),
                onPressed: () => _scrollFeatures(-cardWidth),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.chevron_right,
                    size: 30, color: Colors.grey),
                onPressed: () => _scrollFeatures(cardWidth),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Wraps the about content with its header.
  Widget _aboutMirsadView() {
  return Stack(
    children: [
      Container(
        height: double.infinity,
        width: double.infinity,
        color: const Color(0xFF2184FC).withOpacity(0.76),
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0, left: 22, right: 22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "About Mirsad",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
      // White content container with curved top corners positioned below the header.
      Padding(
        padding: const EdgeInsets.only(top: 180.0), 
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
          child: _aboutContent(),
        ),
      ),
    ],
  );
}

  @override
  void dispose() {
    _featureScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Decide which view to display:
    // If _selectedPersistentIndex is null, we show the About view.
    // Otherwise, we show the corresponding persistent view.
    Widget currentView;
    if (_selectedPersistentIndex == 0) {
      currentView = const chatbot();
    } else if (_selectedPersistentIndex == 2) {
      currentView = const Profile();
    } else {
      currentView = _aboutMirsadView();
    }

    return Scaffold(
      body: currentView,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        height: 70,
        color: const Color(0xFF2184FC).withOpacity(0.65),
        animationDuration: const Duration(milliseconds: 350),
        // Here we set a default index (1) so that the home icon is in the middle.
        // (Even though the About view is shown by default.)
        index: 1,
        onTap: (index) {
          if (index == 1) {
            // When the Home icon is tapped, navigate to Home.dart.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
          } else {
            // For the Chatbot (index 0) and Profile (index 2) icons,
            // update the persistent view.
            setState(() {
              _selectedPersistentIndex = index;
            });
          }
        },
        items: const [
          Icon(Icons.smart_toy_outlined, size: 32, color: Colors.white), // Chatbot → index 0
          Icon(Icons.home, size: 32, color: Colors.white),               // Home → index 1
          Icon(Icons.person, size: 32, color: Colors.white),               // Profile → index 2
        ],
      ),
    );
  }
}  



