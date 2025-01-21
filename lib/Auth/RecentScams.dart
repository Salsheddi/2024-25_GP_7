import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class RecentScams extends StatefulWidget {
  const RecentScams({Key? key}) : super(key: key);

  @override
  State<RecentScams> createState() => _ReportScamState();
}

class _ReportScamState extends State<RecentScams>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 1;
  bool _isNavBarVisible = true;
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String generateContentHash(String content) {
    return content.hashCode.toString();
  }

  Future<void> reportMessage(String content) async {
    final String userId =
        auth.currentUser?.uid ?? ''; // Get the current user's ID
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
                    "Recent Scams",
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
            child: SingleChildScrollView(
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
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 16, bottom: 0, left: 24, right: 22),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "User-Reported Scams",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Handle filter action
                            },
                            icon: const Icon(
                              Icons.filter_list,
                              size: 28,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // List of reported messages
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: getReportedMessages(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('Error loading data.'));
                        }

                        final reportedMessages = snapshot.data ?? [];

                        if (reportedMessages.isEmpty) {
                          return const Center(
                            child: Text(
                              'No reported messages yet.',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reportedMessages.length,
                          itemBuilder: (context, index) {
                            final message = reportedMessages[index];

                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, top: 1, bottom: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // User(s) who reported the message

                                      const SizedBox(height: 6),

                                      Text(
                                        message['content'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      // Report count and icon
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Icon(
                                            Icons.report_gmailerrorred,
                                            color: Color(0xFF2184FC),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${message['reportCount']} reports',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
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
