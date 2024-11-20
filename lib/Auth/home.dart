import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirsad/Auth/Profile.dart';
import 'package:mirsad/Auth/chatbot.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  int _currentIndex = 1;
  final List<Widget> _navigationItem = [
    const Icon(Icons.smart_toy_outlined, size: 32, color: Colors.white),
    const Icon(Icons.home, size: 32, color: Colors.white),
    const Icon(Icons.person, size: 32, color: Colors.white)
  ];

  final List<Widget> _pages = [
    // Replace with actual pages for each navigation item
    chatbot(),
    home(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDECEC),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 4),
            // Logo
            Center(
              child: Container(
                height: 100,
                width: 100, // Set a fixed width

                child: Image.asset(
                  'img/Mirsad2.png',
                ),
              ),
            ),
            SizedBox(height: 5),

            // About MIRSAD
            InkWell(
              onTap: () {
                // Navigate to the fraud detection page when tapped
                /*  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ),
                );*/
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: MediaQuery.of(context).size.width - 32,
                  height: 121,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, // Matches the image's gradient
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2184FC), // Stronger blue on the top left
                        Color(0xFF4D9CFC), // Transition gradient
                        Color(0xFF9AE0EB), // Soft cyan gradient
                        Color(0xFF9AE0EB), // Soft cyan gradient
                      ],
                    ),
                  ),
                  child: Text(
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
            SizedBox(height: 16),

            // AI Fraud Detector Card
            InkWell(
              onTap: () {
                // Navigate to the fraud detection page when tapped
                /*Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FraudDetectionPage()),
                );*/
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: MediaQuery.of(context).size.width - 32,
                  height: 145,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFA4E2EC).withOpacity(0.88),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Text content
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                          'img/sms.png', // Replace with your image asset path
                          height: 128, // Adjust size as needed
                          width: 127,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Reporting and Analytical Report Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reporting Card
                InkWell(
                  onTap: () {
                    // Navigate to the fraud detection page when tapped
                    /*Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ),
                );*/
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2 - 24,
                    height: 230,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              'img/Ellipse5.png', // Replace with your background image
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Diagonal overlay image (top layer)
                        Positioned(
                          top: 72,
                          right: 19,
                          child: Image.asset(
                            'img/report.png', // Replace with your overlay image
                            width: 130, // Adjust width
                            height: 129, // Adjust height
                            fit: BoxFit.contain,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
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
                    // Navigate to the fraud detection page when tapped
                    /* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ),
                );*/
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
                              'img/Frame9.png', // Replace with your background image
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Diagonal overlay image (top layer)
                        Positioned(
                          top: 85,
                          left: 23,
                          child: Image.asset(
                            'img/Anareport.png', // Replace with your image asset
                            height: 126,
                            width: 126,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
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
            Spacer(),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color(0xFFEDECEC),
        height: 70,
        color: const Color(0xFF2184FC).withOpacity(0.65),
        animationDuration: const Duration(milliseconds: 350),
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
