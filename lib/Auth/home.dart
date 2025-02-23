import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:mirsad/Auth/Profile.dart';
import 'package:mirsad/Auth/RecentScams.dart';
import 'package:mirsad/Auth/chatbot.dart';
import 'package:mirsad/Auth/classification.dart';
import 'package:mirsad/Auth/RecentScams.dart';
import 'package:mirsad/Auth/insights.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 1;
  bool _isNavBarVisible = true; // New state to control navbar visibility

  final List<Widget> _navigationItem = [
    const Icon(Icons.smart_toy_outlined, size: 32, color: Colors.white),
    const Icon(Icons.home, size: 32, color: Colors.white),
    const Icon(Icons.person, size: 32, color: Colors.white),
  ];

  final List<Widget> _pages = [
    const chatbot(),
    const HomeContent(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F6),
      body: _pages[_currentIndex],
      bottomNavigationBar: Visibility(
        visible: _isNavBarVisible, // Control visibility of navbar
        child: CurvedNavigationBar(
          backgroundColor: const Color(0xFFF7F6F6),
          height: 70,
          color: const Color(0xFF2184FC).withOpacity(0.65),
          animationDuration: const Duration(milliseconds: 350),
          index: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _isNavBarVisible =
                  true; // Ensure navbar is visible when switching tabs
            });
          },
          items: _navigationItem,
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 4),
            Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: Image.asset('img/Mirsad2.png'),
              ),
            ),
            const SizedBox(height: 20),

            // AI Fraud Detector Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Classification()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.only(left: 14, bottom: 42),
                  child: Row(
                    children: [
                      // Icon aligned with the title
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 29),
                            child: Icon(
                              Icons
                                  .shield_outlined, // Replace with relevant icon
                              size: 32,
                              color: const Color(0xFF2184FC),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8), // Space between icon and text

                      // Text Content
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              Text(
                                'AI Fraud detector',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Protect Against Smishing',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),

            // Discover Section
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0), // Only add left padding
              child: Text(
                'Discover',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Two Cards: Recent Scams and Fraud Insights
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Recent Scams Card
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RecentScams()),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2 - 24,
                    height: 168,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.report_gmailerrorred,
                          size: 36,
                          color: Color(0xFF2184FC),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Recent Scams',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Discover and Avoid Latest Scams',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Fraud Insights Card
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const insights()),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2 - 24,
                    height: 168,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.insights_outlined,
                          size: 36,
                          color: Color(0xFF2184FC),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Message Insights',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'View Insights Of Your Spam And Legitimate Messages',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),

            // About MIRSAD Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: InkWell(
                onTap: () {
                  // Handle navigation to About MIRSAD
                },
                child: Container(
                  width: double.infinity,
                  height: 87,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, top: 16),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Meet MIRSAD!\n',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: '\n', // Adds a blank line
                            style: const TextStyle(
                              fontSize: 5, // Adjust the size for spacing
                            ),
                          ),
                          TextSpan(
                            text: 'Your Trusted Smishing detector',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
