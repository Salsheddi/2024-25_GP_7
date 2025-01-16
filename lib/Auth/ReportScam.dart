import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class ReportScam extends StatefulWidget {
  const ReportScam({Key? key}) : super(key: key);

  @override
  State<ReportScam> createState() => _ReportScamState();
}

class _ReportScamState extends State<ReportScam>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 1;
  bool _isNavBarVisible = true;
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String generateContentHash(String content) {
    return content.hashCode.toString();
  }

  Future<void> reportMessage(String content) async {
  final String userId = auth.currentUser?.uid ?? ''; // Get the current user's ID
  if (userId.isEmpty) {
    _showMessage('User not logged in.');
    return;
  }

  final String contentHash = generateContentHash(content);

  // Check if the user has already reported this message
  final QuerySnapshot existingReport = await firestore
      .collection('reportedMessages')
      .where('contentHash', isEqualTo: contentHash)
      .where('userId', isEqualTo: userId)
      .get();

  if (existingReport.docs.isNotEmpty) {
    _showAlreadyReportedDialog();
    return;
  }

  final String messageId = "RE${DateTime.now().millisecondsSinceEpoch}";

  // Add the new report
  await firestore.collection('reportedMessages').doc(messageId).set({
    'userId': userId,
    'content': content,
    'reportedAt': FieldValue.serverTimestamp(),
    'contentHash': contentHash,
  });

  // Increment the report count
  await incrementReportCount(contentHash, content);

  _showMessage('Message reported successfully.');
}

Future<void> incrementReportCount(String contentHash, String content) async {
  final DocumentReference summaryDoc =
      firestore.collection('reportedMessagesSummary').doc(contentHash);

  await firestore.runTransaction((transaction) async {
    final snapshot = await transaction.get(summaryDoc);

    if (!snapshot.exists) {
      // Initialize the count if it doesn't exist
      transaction.set(summaryDoc, {
        'content': content,
        'reportCount': 1,
        'reportedUsers': [auth.currentUser?.uid],
      });
    } else {
      final data = snapshot.data() as Map<String, dynamic>;
      final List<dynamic> reportedUsers = data['reportedUsers'] ?? [];

      if (!reportedUsers.contains(auth.currentUser?.uid)) {
        // Add the user to the reported users list if not already reported
        reportedUsers.add(auth.currentUser?.uid);
        transaction.update(summaryDoc, {
          'reportCount': reportedUsers.length,
          'reportedUsers': reportedUsers,
        });
      }
    }
  });
}

  void _showAlreadyReportedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message Already Reported'),
          content: const Text(
              'You have already reported this message. No duplicate reports are allowed.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Fetch all the reported messages from the Community tab
  Stream<List<Map<String, dynamic>>> getReportedMessages() {
    return firestore.collection('reportedMessagesSummary').snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return {
            'content': doc['content'],
            'reportCount': doc['reportCount'],
          };
        }).toList();
      },
    );
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 16,
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
                                    controller: _messageController,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText: 'Enter text here..',
                                      hintStyle: const TextStyle(
                                        fontSize: 15,
                                        color: Color.fromARGB(255, 137, 136, 136),
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
                                            color: Colors.blue.withOpacity(0.65)),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -10,
                                    left: -10,
                                    child: GestureDetector(
                                      onTap: () {
                                        _messageController.clear(); // Clear text
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
                                  final content = _messageController.text.trim();
                                  if (content.isEmpty) {
                                    _showMessage('Please enter a message.');
                                    return;
                                  }
                                  reportMessage(content);
                                  _messageController.clear();
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
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Community Tab
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: getReportedMessages(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return const Center(child: Text('Error loading data.'));
                            }

                            final reportedMessages = snapshot.data ?? [];

                            return ListView.builder(
                              itemCount: reportedMessages.length,
                              itemBuilder: (context, index) {
                                final message = reportedMessages[index];
                                return ListTile(
                                  title: Text(message['content']),
                                  subtitle: Text('Reported ${message['reportCount']} times'),
                                );
                              },
                            );
                          },
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
              _currentIndex = index;
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

