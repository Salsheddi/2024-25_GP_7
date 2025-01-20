import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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

// convert image to text
  String? _result; // To store the result from the API
  File? _image; // To store image
  final ImagePicker _picker =
      ImagePicker(); // Create an instance of ImagePicker

  String? _extractedText = ''; // Store the initial extracted text
  bool _isTextEdited = false; // Flag to track if the text has been edited
  bool _isTextSet = false; // Flag to track if the extracted text has been set

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Store the image file
        _messageController
            .clear(); // Clear any existing text in the field immediately
        _isTextEdited =
            false; // Reset the edit flag to prevent premature image removal
        _extractedText = ''; // Reset the extracted text
        _isTextSet = false; // Reset the flag to false
      });

      // Extract text from the image once uploaded
      await _extractTextFromImage();
    }
  }

  Future<void> _extractTextFromImage() async {
    if (_image == null) return;
    try {
      final textRecognizer = TextRecognizer();
      final InputImage inputImage = InputImage.fromFile(_image!);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      setState(() {
        // Set extracted text to the text field
        _messageController.text = recognizedText.text;
        _extractedText = recognizedText.text; // Store the extracted text
        _isTextSet = true; // Mark that the extracted text has been set
      });

      textRecognizer.close();
    } catch (e) {
      setState(() {
        _result = "Error extracting text: $e";
      });
    }
  }

// Reset function
  void _resetContent() {
    _messageController.clear(); // Clear the text field
    setState(() {
      _image = null; // Clear the image
      _result = null; // Clear the result
      _isTextSet = false; // Reset the text set flag
    });
  }

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
    // Notifiers for hover effects
    ValueNotifier<bool> isImageHovered = ValueNotifier(false);
    ValueNotifier<bool> isButtonHovered = ValueNotifier(false);
    ValueNotifier<bool> isButtonPressed = ValueNotifier(false);

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
            child: SingleChildScrollView(
              // Wrap content in scrollable widget
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
                    SizedBox(
                        height: MediaQuery.of(context).size.height -
                            200, // Adjust the height
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Report Tab
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 25.0, left: 30, right: 30),
                              child: Expanded(
                                // Wrap the Column inside Expanded to prevent overflow
                                child: SingleChildScrollView(
                                  // Allow scrolling inside the Report tab
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Help us keep the community safe by reporting any fraudulent messages.",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
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
                                                color: Color.fromARGB(
                                                    255, 137, 136, 136),
                                              ),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                              fillColor: Colors.grey[200],
                                              filled: true,
                                              suffixIcon: IconButton(
                                                onPressed: () {
                                                  // Handle file upload
                                                  _pickImage();
                                                },
                                                icon: Icon(Icons.attach_file,
                                                    size: 25,
                                                    color: Colors.blue
                                                        .withOpacity(0.65)),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: -10,
                                            left: -10,
                                            child: GestureDetector(
                                              onTap: () {
                                                _messageController
                                                    .clear(); // Clear text
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
                                      if (_image != null)
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            ValueListenableBuilder<bool>(
                                              valueListenable: isImageHovered,
                                              builder: (context, hover, child) {
                                                return MouseRegion(
                                                  onEnter: (_) => isImageHovered
                                                      .value = true,
                                                  onExit: (_) => isImageHovered
                                                      .value = false,
                                                  child: AnimatedContainer(
                                                    duration: const Duration(
                                                        milliseconds: 200),
                                                    height: hover ? 140 : 120,
                                                    width: hover ? 140 : 120,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          width: 1),
                                                    ),
                                                    child: Image.file(
                                                      _image!,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            Positioned(
                                              top: -10,
                                              left: -10,
                                              child: GestureDetector(
                                                onTap: _resetContent,
                                                child: Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(
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
                                          final content =
                                              _messageController.text.trim();
                                          if (content.isEmpty) {
                                            _showMessage(
                                                'Please enter a message.');
                                            return;
                                          }
                                          reportMessage(content);
                                          _resetContent(); // Reset both the text field and the image
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF2184FC),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 32, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          "Report Message",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Community Tab
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
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  shrinkWrap:
                                      true, // Ensures ListView only takes up as much space as needed
                                  itemCount: reportedMessages.length,
                                  itemBuilder: (context, index) {
                                    final message = reportedMessages[index];

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // User(s) who reported the message
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.person,
                                                    size: 20,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      'Reported by: ${message['reportedUsers']?.join(', ') ?? 'Unknown'}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),

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
                            )
                          ],
                        )),
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
