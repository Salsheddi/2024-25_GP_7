import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mirsad/Auth/Profile.dart';
import 'package:mirsad/Auth/chatbot.dart';
import 'dart:io';
import 'package:mirsad/Auth/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class Classification extends StatefulWidget {
  const Classification({super.key});

  @override
  State<Classification> createState() => _ClassificationState();
}

class _ClassificationState extends State<Classification> {
  int _currentIndex = 1; // Default to the second tab (Home)
  bool _isNavBarVisible = true; // To control visibility of the navbar

  final TextEditingController _textController = TextEditingController();
  String? _result; // To store the result from the API
  File? _image; // To store image
  final ImagePicker _picker = ImagePicker(); // Instance for picking image

  String? _extractedText = ''; // Store the initially extracted text
  bool _isTextEdited = false; // Flag to track if the text has been edited
  bool _isTextSet = false; // Flag to track if the extracted text has been set

  @override
  void initState() {
    super.initState();

    // Listen for text changes. If the user edits the text after an image was set, remove the image.
    _textController.addListener(() {
      if (_isTextSet &&
          _textController.text != _extractedText &&
          _image != null) {
        setState(() {
          _isTextEdited = true;
          _image = null;
        });
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _textController.clear();
        _isTextEdited = false;
        _extractedText = '';
        _isTextSet = false;
      });
      await _extractTextFromImage();
    }
  }

  // Reset the content (clear image, text and result)
  void _resetContent() {
    _textController.clear();
    setState(() {
      _image = null;
      _result = null;
      _isTextSet = false;
    });
  }

  Future<void> _extractTextFromImage() async {
    if (_image == null) return;
    try {
      final textRecognizer = TextRecognizer();
      final InputImage inputImage = InputImage.fromFile(_image!);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      setState(() {
        _textController.text = recognizedText.text;
        _extractedText = recognizedText.text;
        _isTextSet = true;
      });

      textRecognizer.close();
    } catch (e) {
      setState(() {
        _result = "Error extracting text: $e";
      });
    }
  }

  /// Checks if the user has detected this message in the last 24 hours.
  Future<bool> canDetectMessage(String userId, String message) async {
    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('messages')
          .where('userId', isEqualTo: userId)
          .where('message', isEqualTo: message)
          .where('type', isEqualTo: 'detection')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        print("No previous detections found.");
        return true; // Allow detection if no previous record exists.
      }

      Timestamp lastTimestamp = query.docs.first.get('timestamp');
      print("Last detection timestamp: ${lastTimestamp.toDate()}");

      // Allow detection only if more than 24 hours have passed.
      return DateTime.now().difference(lastTimestamp.toDate()).inHours >= 24;
    } catch (e) {
      print("Error in canDetectMessage: $e");
      return true; // On error, allow detection.
    }
  } 

  void _showDetectionLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detection Limit Reached'),
        content:
            const Text('You can only detect this message once every 24 hours.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // 2. Save the detection record in Firestore.
  Future<void> saveDetection({
    required String userId,
    required String message,
    required String label,
    required String percentage,
    required String justification,
  }) async {
    try {
      String id = 'DE${DateTime.now().millisecondsSinceEpoch}';
      print("Saving detection with ID: $id");
      print("Message: $message");
      print(
          "Label: $label, Percentage: $percentage, Justification: $justification");

      await FirebaseFirestore.instance.collection('messages').doc(id).set({
        'id': id,
        'userId': userId,
        'message': message,
        'label': label,
        'percentage': percentage,
        'justification': justification,
        'type': 'detection',
        'timestamp': Timestamp.now(),
      });

      print("Detection saved to Firestore successfully!");
    } catch (e) {
      print("Error saving detection: $e");
    }
  }

  // 3. Process detection by saving and updating the summary.
  Future<void> processDetection({
    required String userId,
    required String message,
    required String classification,
    required String justification,
    required String likelihood,
  }) async {
    try {
      print("Processing detection for message: $message");
      await saveDetection(
        userId: userId,
        message: message,
        label: classification,
        percentage: likelihood,
        justification: justification,
      );
      await updateDetectionSummary(message, userId);
      print("Detection processed and saved successfully!");
    } catch (e) {
      print("Error processing detection: $e");
    }
  }

  // 4. Update the per-user detection summary.
  Future<void> updateDetectionSummary(String message, String userId) async {
    try {
      String hash = generateHash(message);
      String docId = '$hash';
      DocumentReference ref = FirebaseFirestore.instance
          .collection('detectedMessagesSummary')
          .doc(docId);
      DocumentSnapshot snapshot = await ref.get();
      if (snapshot.exists) {
        await ref.update({
          'counter': FieldValue.increment(1),
        });
      } else {
        await ref.set({
          'messageContent': message,
          'hashContent': hash,
          'userId': userId,
          'counter': 1,
        });
      }
    } catch (e) {
      print("Error updating detection summary: $e");
    }
  }

  // A simple hash function.
  String generateHash(String message) {
    return message.hashCode.toString();
  }

  // 5. Retrieve the most recent detection for the message.
  Future<DocumentSnapshot?> getLatestDetection(
      String userId, String message) async {
    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('messages')
          .where('userId', isEqualTo: userId)
          .where('message', isEqualTo: message)
          .where('type', isEqualTo: 'detection')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return query.docs.first;
    } catch (e) {
      print("Error retrieving latest detection: $e");
      return null;
    }
  }

  // --- Reporting Functions ---
  /// Checks if the user has reported this [message] in the last 24 hours.
  Future<bool> canReportMessage(String userId, String message) async {
    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('messages')
          .where('userId', isEqualTo: userId)
          .where('message', isEqualTo: message)
          .where('type', isEqualTo: 'report')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return true;

      Timestamp lastTimestamp = query.docs.first.get('timestamp');
      print("Last report timestamp: ${lastTimestamp.toDate()}");

      // Check if the last report is within the last 24 hours
      bool isWithin24Hours =
          DateTime.now().difference(lastTimestamp.toDate()).inHours < 24;

      if (isWithin24Hours) {
        // Show a dialog if the report was within 24 hours
        _showReportLimitDialog();
      }

      return !isWithin24Hours; // Return false if within 24 hours
    } catch (e) {
      print("Error in canReportMessage: $e");
      return true; // In case of error, allow reporting
    }
  }

  void _showReportLimitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report Limit Reached'),
          content: const Text('You can only report this message once every 24 hours.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Saves the report record in Firestore with an ID starting with "RE".
  Future<void> saveReport({
    required String userId,
    required String message,
    required String label,
  }) async {
    try {
      String id = 'RE${DateTime.now().millisecondsSinceEpoch}';
      await FirebaseFirestore.instance.collection('messages').doc(id).set({
        'id': id,
        'userId': userId,
        'message': message,
        'label': label,
        'type': 'report',
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print("Error saving report: $e");
    }
  }

  Future<void> _reportMessage() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    String message = _textController.text;
    if (message.isEmpty) return;

    bool allowed = await canReportMessage(userId, message);
    if (!allowed) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Report Rejected.')));
      return;
    }

    // Retrieve the label from the current _result.
    String label;
    try {
      RegExp regExp = RegExp(r"\*\*Label:\*\*\s*(\w+)");
      Match? match = regExp.firstMatch(_result ?? '');
      label = (match != null ? match.group(1)?.toLowerCase() : "unknown") ??
          "unknown";
    } catch (e) {
      label = "unknown";
    }

    await saveReport(userId: userId, message: message, label: label);
    await updateReportSummary(message, userId);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message reported successfully.')));
  }

  /// Updates the reported messages summary.
  Future<void> updateReportSummary(String message, String userId) async {
    try {
      String hash = generateHash(message);
      DocumentReference ref = FirebaseFirestore.instance
          .collection('reportedMessagesSummary')
          .doc(hash);
      DocumentSnapshot snapshot = await ref.get();
      if (snapshot.exists) {
        await ref.update({
          'counter': FieldValue.increment(1),
          'reportedUsers': FieldValue.arrayUnion([userId]),
        });
      } else {
        await ref.set({
          'messageContent': message,
          'hashContent': hash,
          'counter': 1,
          'reportedUsers': [userId],
        });
      }
    } catch (e) {
      print("Error updating report summary: $e");
    }
  }

  // -------------------------------
  // Updated _checkMessage Function
  // ------------------------------- 
  Future<void> _checkMessage() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    String message = _textController.text;
    if (message.isEmpty) return;

    // Check if the message can be detected.
    bool allowedToDetect = await canDetectMessage(userId, message);

    // If detection already occurred within 24 hours, display its details.
    if (!allowedToDetect) {
      DocumentSnapshot? doc = await getLatestDetection(userId, message);
      if (doc != null) {
        String label = doc.get('label');
        String percentage = doc.get('percentage');
        String justification = doc.get('justification');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Already Detected'),
            content: Text(
                'You already processed this message in the last 24 hours.\n\nClassification: $label\nJustification: $justification\nLikelihood: $percentage'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              )
            ],
          ),
        );
        setState(() {
          _result =
              "**Label:** $label\n**Justification:** $justification\n**Likelihood:** $percentage";
        });
        return;
      }
    }

    // --- Begin HTTP call to the classifier API ---
    String baseUrl =
        "https://shdnalssheddi-mirsad-classifier.hf.space/gradio_api/call/predict";
    try {
      Map<String, dynamic> payload = {"data": [message]};
      final postResponse = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );

      print("POST status: ${postResponse.statusCode}");
      print("POST response body: ${postResponse.body}");

      if (postResponse.statusCode == 200) {
        final postResponseBody = json.decode(postResponse.body);
        if (postResponseBody['event_id'] != null) {
          String eventId = postResponseBody['event_id'];
          String resultUrl = "$baseUrl/$eventId";
          final getResponse = await http.get(Uri.parse(resultUrl));
          print("GET status: ${getResponse.statusCode}");
          print("GET response body: ${getResponse.body}");

          if (getResponse.statusCode == 200) {
            String responseBody = getResponse.body;
            if (responseBody.startsWith("event:")) {
              final dataIndex = responseBody.indexOf("data: ");
              if (dataIndex != -1) {
                String dataPart = responseBody.substring(dataIndex + 6).trim();
                try {
                  final parsedData = json.decode(dataPart);
                  if (parsedData is List && parsedData.isNotEmpty) {
                    String resultString = parsedData[0];
                    print("Parsed result string: $resultString");
                    List<String> parts = resultString.split('\n');
                    print("Parts: $parts");

                    // Extract label, justification, and likelihood depending on the number of parts
                    String classification = "";
                    String justification = "";
                    String likelihood = "";

                    if (parts.isNotEmpty) {
                      classification =
                          parts[0].replaceAll("**Label:**", "").trim();
                    }
                    if (parts.length >= 2) {
                      justification =
                          parts[1].replaceAll("**Justification:**", "").trim();
                    }
                    if (parts.length >= 3) {
                      if (parts[2].contains("Spam Probability:")) {
                        likelihood =
                            parts[2].replaceAll("**Spam Probability:**", "").trim();
                      } else if (parts[2].contains("Likelihood:")) {
                        likelihood =
                            parts[2].replaceAll("**Likelihood:**", "").trim();
                      } else {
                        likelihood = parts[2].trim();
                      }
                    }

                    setState(() {
                      _result =
                          "**Label:** $classification\n**Justification:** $justification\n**Likelihood:** $likelihood";
                    });

                    // Save detection only if allowed.
                    if (allowedToDetect) {
                      await processDetection(
                        userId: userId,
                        message: message,
                        classification: classification,
                        justification: justification,
                        likelihood: likelihood,
                      );
                    }
                  } else {
                    setState(() {
                      _result = "Error: Parsed data is not a valid list.";
                    });
                  }
                } catch (e) {
                  setState(() {
                    _result = "Error parsing response data: $e";
                  });
                }
              } else {
                setState(() {
                  _result = "Error: 'data' part not found in response.";
                });
              }
            } else {
              setState(() {
                _result = "Error: Unexpected GET response format.";
              });
            }
          } else {
            setState(() {
              _result = "Error: GET request failed (${getResponse.statusCode}).";
            });
          }
        } else {
          setState(() {
            _result = "Error: 'event_id' not found in POST response.";
          });
        }
      } else {
        setState(() {
          _result = "Error: POST request failed (${postResponse.statusCode}).";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Error during HTTP call: $e";
      });
    }
  }

  // -------------------------------
  // Build Method with Navigation
  // -------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDECEC),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const chatbot(),
          ClassificationContent(
            pickImage: _pickImage,
            image: _image,
            textController: _textController,
            onCheckMessage: _checkMessage,
            result: _result,
            onReset: _resetContent,
            onReportMessage: _reportMessage, // Pass report callback
          ),
          const Profile(),
        ],
      ),
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
              if (index == 1) {
                _currentIndex = 0;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              } else {
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

// ---------------------------------------------------------------------
// ClassificationContent Widget
// ---------------------------------------------------------------------
class ClassificationContent extends StatelessWidget {
  final Future<void> Function() pickImage;
  final File? image;
  final TextEditingController textController;
  final Future<void> Function() onCheckMessage;
  final String? result;
  final VoidCallback onReset;
  final Future<void> Function()? onReportMessage;

  const ClassificationContent({
    super.key,
    required this.pickImage,
    required this.image,
    required this.textController,
    required this.onCheckMessage,
    required this.result,
    required this.onReset,
    this.onReportMessage,
  });

  @override
  Widget build(BuildContext context) {
    // Notifiers for hover/press effects.
    ValueNotifier<bool> isImageHovered = ValueNotifier(false);
    ValueNotifier<bool> isCheckButtonHovered = ValueNotifier(false);
    ValueNotifier<bool> isCheckButtonPressed = ValueNotifier(false);
    ValueNotifier<bool> isReportButtonHovered = ValueNotifier(false);
    ValueNotifier<bool> isReportButtonPressed = ValueNotifier(false);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F6),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 100,
                width: double.infinity,
                color: const Color(0xFF2184FC),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    IconButton(
                      icon:
                          const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Mirsad's Fraud Detector",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Got a suspicious message?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Let’s find out if it’s legitimate or a spam!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              TextFormField(
                                controller: textController,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  hintText:
                                      'Enter text here OR upload screenshot of your message',
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[600],
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(8.0)),
                                  fillColor: Colors.grey[200],
                                  filled: true,
                                  suffixIcon: IconButton(
                                    onPressed: pickImage,
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
                                  onTap: onReset,
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
                          const SizedBox(height: 14),
                          if (image != null)
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ValueListenableBuilder<bool>(
                                  valueListenable: isImageHovered,
                                  builder: (context, hover, child) {
                                    return MouseRegion(
                                      onEnter: (_) =>
                                          isImageHovered.value = true,
                                      onExit: (_) =>
                                          isImageHovered.value = false,
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 200),
                                        height: hover ? 140 : 120,
                                        width: hover ? 140 : 120,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border: Border.all(
                                              color: Colors.grey,
                                              width: 1),
                                        ),
                                        child: Image.file(
                                          image!,
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
                                    onTap: onReset,
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
                          const SizedBox(height: 16),
                          // Row for Check Message (and conditionally Report Message)
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ValueListenableBuilder<bool>(
                                  valueListenable: isCheckButtonHovered,
                                  builder: (context, hover, child) {
                                    return GestureDetector(
                                      onTapDown: (_) =>
                                          isCheckButtonPressed.value = true,
                                      onTapUp: (_) =>
                                          isCheckButtonPressed.value = false,
                                      onTapCancel: () =>
                                          isCheckButtonPressed.value = false,
                                      onTap: () async {
                                        await onCheckMessage();
                                      },
                                      child: MouseRegion(
                                        onEnter: (_) =>
                                            isCheckButtonHovered.value =
                                                true,
                                        onExit: (_) =>
                                            isCheckButtonHovered.value =
                                                false,
                                        child: ValueListenableBuilder<bool>(
                                          valueListenable:
                                              isCheckButtonPressed,
                                          builder: (context, pressed, child) {
                                            return AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: pressed
                                                    ? const Color.fromARGB(
                                                        255, 28, 73, 134)
                                                    : hover
                                                        ? const Color.fromARGB(
                                                                255, 165, 203, 248)
                                                            .withOpacity(
                                                                0.85)
                                                        : const Color(0xFF2184FC)
                                                            .withOpacity(0.65),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: const Text(
                                                'Check Message',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Conditionally display Report Message button if result exists and label is SPAM.
                              if (result != null &&
                                  _extractLabel(result!) == "SPAM") ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ValueListenableBuilder<bool>(
                                    valueListenable: isReportButtonHovered,
                                    builder: (context, hover, child) {
                                      return GestureDetector(
                                        onTapDown: (_) =>
                                            isReportButtonPressed.value = true,
                                        onTapUp: (_) =>
                                            isReportButtonPressed.value = false,
                                        onTapCancel: () =>
                                            isReportButtonPressed.value = false,
                                        onTap: () async {
                                          if (onReportMessage != null) {
                                            await onReportMessage!();
                                          }
                                        },
                                        child: MouseRegion(
                                          onEnter: (_) =>
                                              isReportButtonHovered.value =
                                                  true,
                                          onExit: (_) =>
                                              isReportButtonHovered.value =
                                                  false,
                                          child: ValueListenableBuilder<bool>(
                                            valueListenable:
                                                isReportButtonPressed,
                                            builder: (context, pressed, child) {
                                              return AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: pressed
                                                      ? const Color.fromARGB(
                                                          255, 134, 28, 28)
                                                      : hover
                                                          ? const Color.fromARGB(
                                                                  255,
                                                                  248,
                                                                  165,
                                                                  165)
                                                              .withOpacity(0.85)
                                                          : const Color.fromARGB(
                                                                  255,
                                                                  255,
                                                                  0,
                                                                  0)
                                                              .withOpacity(0.65),
                                                  borderRadius:
                                                      BorderRadius.circular(8.0),
                                                ),
                                                child: const Text(
                                                  'Report Message',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ]
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Modified result display: show label, justification, and likelihood.
                          if (result != null) _buildResultDisplay(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Extracts the label from the API result.
  String _extractLabel(String result) {
    RegExp regExp = RegExp(r"\*\*Label:\*\*\s*(\w+)");
    Match? match = regExp.firstMatch(result);
    if (match != null) {
      String label = match.group(1)?.toLowerCase() ?? "unknown";
      if (label == "spam") return "SPAM";
      if (label == "not") return "LEGITIMATE";
    }
    return "NOT FOUND";
  }

  TextStyle _getTextStyle(String result) {
    String label = _extractLabel(result);
    if (label == "SPAM") {
      return const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red);
    } else if (label == "LEGITIMATE") {
      return const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green);
    } else {
      return const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black);
    }
  }

  TextStyle _extractLabelStyle(String result) => _getTextStyle(result);
  TextStyle _extractJustificationStyle(String result) => _getTextStyle(result);
  TextStyle _extractLikelihoodStyle(String result) => _getTextStyle(result);

  /// Builds the display widget for the detection result.
  Widget _buildResultDisplay() {
  // Expected format of result:
  // **Label:** Spam
  // **Justification:** Contains spam-related keywords.
  // **Likelihood:** 99.74%
  final lines = result!.split('\n');
  String labelText = lines.isNotEmpty
      ? lines[0].replaceAll("**Label:**", "").trim()
      : "N/A";
  String justificationText = lines.length > 1
      ? lines[1].replaceAll("**Justification:**", "").trim()
      : "N/A";
  String likelihoodText = lines.length > 2
      ? lines[2]
          .replaceAll("**Likelihood:**", "")
          .replaceAll("**Spam Probability:**", "")
          .trim()
      : "N/A";

  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text("Label: $labelText", style: _extractLabelStyle(result!)),
      const SizedBox(height: 8),
      Text("Justification: $justificationText",
          style: _extractJustificationStyle(result!),
          textAlign: TextAlign.center), // <-- Centered text
      const SizedBox(height: 8),
      Text("Likelihood: $likelihoodText",
          style: _extractLikelihoodStyle(result!),
          textAlign: TextAlign.center),
    ],
  );
}
}
