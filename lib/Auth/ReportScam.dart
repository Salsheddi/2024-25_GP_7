import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class ReportScam extends StatefulWidget {
  const ReportScam({Key? key}) : super(key: key);

  @override
  State<ReportScam> createState() => _ReportScamState();
}

class _ReportScamState extends State<ReportScam>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 1; // Default to the second tab (Home)
  bool _isNavBarVisible = true; // To control visibility of the navbar

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDECEC),
      body: Stack(
        children: [
          // Blue header background with title
          Container(
            height: 200,
            width: double.infinity,
            color: const Color(0xFF2184FC).withOpacity(0.76),
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 63.0, left: 16.0, right: 16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Go back to the previous screen
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Report a Scam",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // White content area with rounded corners
          Padding(
            padding: const EdgeInsets.only(top: 115.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Color(0xFFF7F6F6),
              ),
              child: Column(
                children: [
                  // Tab bar
                  TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF2184FC),
                    indicatorWeight: 3,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(
                      // Style for selected tabs
                      fontSize: 18, // Adjust this size
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      // Style for unselected tabs
                      fontSize: 16, // Adjust this size
                    ),
                    tabs: const [
                      Tab(text: "Report"),
                      Tab(text: "Community"),
                    ],
                  ),

                  // Tab bar views
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Report Tab
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 45.0, left: 30, right: 30),
                          child: Column(
                            children: [
                              // Text area with delete button
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  TextFormField(
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText: 'Enter text here..',
                                      hintStyle: const TextStyle(
                                        fontSize: 15,
                                        color:
                                            Color.fromARGB(255, 137, 136, 136),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0)),
                                      fillColor: Colors.grey[200],
                                      filled: true,
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          // Handle file upload
                                        },
                                        icon: Icon(Icons.attach_file,
                                            size: 25,
                                            color:
                                                Colors.blue.withOpacity(0.65)),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -10,
                                    left: -10,
                                    child: GestureDetector(
                                      onTap: () {
                                        // Handle delete action
                                      },
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Report Message button
                              ElevatedButton(
                                onPressed: () {
                                  // Handle button press
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2184FC),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "Report Message",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Community Tab
                        Center(
                          child: Text(
                            "Community Page",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Visibility(
        visible: _isNavBarVisible,
        child: CurvedNavigationBar(
          backgroundColor: const Color(0xFFF7F6F6),
          height: 70,
          color: const Color(0xFF2184FC).withOpacity(0.65),
          animationDuration: const Duration(milliseconds: 350),
          index: _currentIndex,
          onTap: (index) {
            setState(() {
              // If the Home button (index 1) is clicked, go directly to Home (index 0)
              if (index == 1) {
                // Directly navigate to Home page
                _currentIndex = 0;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportScam()),
                );
              } else {
                // Update the current index based on the tapped tab
                _currentIndex = index;
              }
            });
          },
          items: const [
            Icon(Icons.smart_toy_outlined, size: 32, color: Colors.white),
            Icon(Icons.home, size: 32, color: Colors.white),
            Icon(Icons.person, size: 32, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
