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
  bool _showOnlyMyReports = false;

  String selectedSortOption = 'new_to_old'; // Default sorting option

  String generateContentHash(String content) {
    return content.hashCode.toString();
  }

  Future<void> incrementReportCount(String contentHash, String content) async {
    final DocumentReference summaryDoc =
        firestore.collection('reportedMessagesSummary').doc(contentHash);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(summaryDoc);

      if (!snapshot.exists) {
        transaction.set(summaryDoc, {
          'messageContent': content,
          'counter': 1,
          'reportedUsers': [auth.currentUser?.uid],
          'latestReportTime':
              FieldValue.serverTimestamp(), // Store latest report time
        });
      } else {
        final data = snapshot.data() as Map<String, dynamic>;
        final List<dynamic> reportedUsers = data['reportedUsers'] ?? [];

        if (!reportedUsers.contains(auth.currentUser?.uid)) {
          reportedUsers.add(auth.currentUser?.uid);
          transaction.update(summaryDoc, {
            'counter': reportedUsers.length,
            'reportedUsers': reportedUsers,
            'latestReportTime': FieldValue.serverTimestamp(), // Add this field
          });
        }
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Fetch reported messages and apply sorting
  Stream<List<Map<String, dynamic>>> getReportedMessages() {
    final currentUserId = auth.currentUser?.uid;

    return firestore.collection('reportedMessagesSummary').snapshots().map(
      (snapshot) {
        final messages = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final reportedUsers = List<String>.from(data['reportedUsers'] ?? []);

          final latestReportTime = data['latestReportTime'] as Timestamp?;

          return {
            'messageContent': data['messageContent'] ?? 'Unknown Content',
            'counter': data['counter'] ?? 0,
            'latestReportTime': latestReportTime,
            'reportedUsers': reportedUsers,
          };
        }).where((message) {
          if (_showOnlyMyReports && currentUserId != null) {
            return message['reportedUsers'].contains(currentUserId);
          }
          return true; // Show all if not filtering
        }).toList();

        // Your existing sorting logic here...
        switch (selectedSortOption) {
          case 'new_to_old':
            messages.sort((a, b) {
              final aTimestamp = a['latestReportTime'] as Timestamp?;
              final bTimestamp = b['latestReportTime'] as Timestamp?;

              // Use earliest possible timestamp if null
              final aTime =
                  aTimestamp ?? Timestamp.fromMillisecondsSinceEpoch(0);
              final bTime =
                  bTimestamp ?? Timestamp.fromMillisecondsSinceEpoch(0);

              return bTime.compareTo(aTime); // Sort newest to oldest
            });
            break;
          case 'old_to_new':
            messages.sort((a, b) {
              final aTimestamp = a['latestReportTime'] as Timestamp?;
              final bTimestamp = b['latestReportTime'] as Timestamp?;

              // Use earliest possible timestamp if null
              final aTime =
                  aTimestamp ?? Timestamp.fromMillisecondsSinceEpoch(0);
              final bTime =
                  bTimestamp ?? Timestamp.fromMillisecondsSinceEpoch(0);

              return aTime.compareTo(bTime); // Sort oldest to newest
            });
            break;
          case 'most_to_least':
            messages.sort((a, b) {
              // Sort by most reports
              return b['counter'].compareTo(a['counter']);
            });
            break;
          case 'least_to_most':
            messages.sort((a, b) {
              // Sort by least reports
              return a['counter'].compareTo(b['counter']);
            });
            break;
        }

        return messages;
      },
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('Newest to Oldest', 'new_to_old'),
              _buildFilterOption('Oldest to Newest', 'old_to_new'),
              _buildFilterOption('Most Reported to Least', 'most_to_least'),
              _buildFilterOption('Least Reported to Most', 'least_to_most'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: selectedSortOption == value
          ? const Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () {
        setState(() {
          selectedSortOption = value;
        });
        Navigator.pop(context); // Close modal
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDECEC),
      body: Stack(
        children: [
          // Blue header background
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
                      Navigator.pop(context);
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

          // Content area
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
                          Row(
                            children: [
                              Tooltip(
                                message: _showOnlyMyReports
                                    ? "Showing only messages you reported"
                                    : "Click to show only messages you reported",
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: const TextStyle(color: Colors.white),
                                waitDuration: const Duration(milliseconds: 500),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.person_search,
                                    size: 28,
                                    color: _showOnlyMyReports
                                        ? Colors.blue
                                        : Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showOnlyMyReports = !_showOnlyMyReports;
                                    });
                                  },
                                ),
                              ),
                              IconButton(
                                onPressed: _showFilterOptions,
                                icon: const Icon(
                                  Icons.filter_list,
                                  size: 28,
                                  color: Colors.black,
                                ),
                              ),
                            ],
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

                        final reportedMessages = snapshot.data;

                        // Ensure that the list is properly checked
                        if (reportedMessages == null ||
                            reportedMessages.isEmpty) {
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
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
                                      Text(
                                        message['messageContent'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
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
                                            '${message['counter']} reports',
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
                    )
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
