import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:mirsad/Auth/Profile.dart';
import 'package:mirsad/Auth/chatbot.dart';
import 'package:mirsad/Auth/classification.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Current index of the bottom navigation bar
  int _currentIndex = 1;

  // Navigation items (icons)
  final List<Widget> _navigationItem = [
    const Icon(Icons.smart_toy_outlined, size: 32, color: Colors.white),
    const Icon(Icons.home, size: 32, color: Colors.white),
    const Icon(Icons.person, size: 32, color: Colors.white),
  ];

  // Corresponding pages for each navigation item
  final List<Widget> _pages = [
    const chatbot(), // Chatbot widget
    const HomeContent(), // Home content widget
    const Profile(), // Profile page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDECEC),
      body: _pages[_currentIndex], // Display the selected page
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color(0xFFEDECEC),
        height: 70,
        color: const Color(0xFF2184FC).withOpacity(0.65),
        animationDuration: const Duration(milliseconds: 350),
        index: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the current page index
          });
        },
        items: _navigationItem,
      ),
    );
  }
}

// Widget for the main content of the "Home" page
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 4),
          // Logo
          Center(
            child: SizedBox(
              height: 100,
              width: 100, // Set a fixed width
              child: Image.asset('img/Mirsad2.png'),
            ),
          ),
          const SizedBox(height: 5),

          // About MIRSAD
          InkWell(
            onTap: () {
              // Handle tap for About MIRSAD
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: MediaQuery.of(context).size.width - 32,
                height: 121,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2184FC),
                      Color(0xFF4D9CFC),
                      Color(0xFF9AE0EB),
                      Color(0xFF9AE0EB),
                    ],
                  ),
                ),
                child: const Text(
                  'About MIRSAD!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // AI Fraud Detector Card
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Classification()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: MediaQuery.of(context).size.width - 32,
                height: 145,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFA4E2EC).withOpacity(0.88),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'AI Fraud Detector',
                          style: TextStyle(
                            color: Color(0xFF1A58A2),
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Protect Against Smishing',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    // Image on the right
                    Opacity(
                      opacity: 0.65,
                      child: Image.asset(
                        'img/sms.png',
                        height: 128,
                        width: 127,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Reporting and Analytical Report Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Reporting Card
              InkWell(
                onTap: () {
                  // Handle tap for Reporting
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 2 - 24,
                  height: 230,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            'img/Ellipse5.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 72,
                        right: 19,
                        child: Image.asset(
                          'img/report.png',
                          width: 130,
                          height: 129,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Reporting',
                          style: TextStyle(
                            color: Color(0xFF1E6BC8),
                            fontSize: 23.56,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Analytical Report Card
              InkWell(
                onTap: () {
                  // Handle tap for Analytical Report
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 2 - 24,
                  height: 230,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            'img/Frame9.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 85,
                        left: 23,
                        child: Image.asset(
                          'img/Anareport.png',
                          height: 126,
                          width: 126,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Analytical Report',
                          style: TextStyle(
                            color: Color(0xFF1E6BC8),
                            fontSize: 23.56,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

