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
import 'package:curved_navigation_bar/curved_navigation_bar.dart'; // Import for the bottom navigation bar

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
  final ImagePicker _picker =
      ImagePicker(); // Create an instance of ImagePicker

  String? _extractedText = ''; // Store the initial extracted text
  bool _isTextEdited = false; // Flag to track if the text has been edited
  bool _isTextSet = false; // Flag to track if the extracted text has been set

  @override
  void initState() {
    super.initState();

    // Add a listener to the TextEditingController to detect changes in the text field
    _textController.addListener(() {
      // Only remove the image if the text is edited by the user, after it's been set
      if (_isTextSet &&
          _textController.text != _extractedText &&
          _image != null) {
        setState(() {
          _isTextEdited = true; // Mark as edited to prevent repeated triggers
          _image = null; // Remove image after the user starts editing
        });
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Store the image file
        _textController
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

// Reset function
  void _resetContent() {
    _textController.clear(); // Clear the text field
    setState(() {
      _image = null; // Clear the image
      _result = null; // Clear the result
      _isTextSet = false; // Reset the text set flag
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
        // Set extracted text to the text field
        _textController.text = recognizedText.text;
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

  // API calling to Huggingface space -shdn
  Future<void> _checkMessage() async {
    String baseUrl =
        "https://shdnalssheddi-mirsad-classifier.hf.space/gradio_api/call/predict";
    try {
      // Prepare the payload
      Map<String, dynamic> payload = {
        "data": [_textController.text]
      };

      // Make the POST request
      final postResponse = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );

      if (postResponse.statusCode == 200) {
        final postResponseBody = json.decode(postResponse.body);

        if (postResponseBody['event_id'] != null) {
          String eventId = postResponseBody['event_id'];
          String resultUrl = "$baseUrl/$eventId";

          // Fetch the result
          final getResponse = await http.get(Uri.parse(resultUrl));

          if (getResponse.statusCode == 200) {
            // Check if the response starts with "event:"
            String responseBody = getResponse.body;
            if (responseBody.startsWith("event:")) {
              // Extract the "data" part
              final dataIndex = responseBody.indexOf("data: ");
              if (dataIndex != -1) {
                String dataPart = responseBody
                    .substring(dataIndex + 6)
                    .trim(); // Get content after "data: "
                try {
                  // Try to parse as JSON if possible
                  final parsedData = json.decode(dataPart);

                  // Extract the classification result
                  String classification = parsedData["data"][0][0];
                  String justification = parsedData["data"][0][1];
                  String likelihood = parsedData["data"][0][2];

                  // Display the label, hold justification and likelihood for now
                  setState(() {
                    _result = """
                      Classification: 
                      \x1B[31m\x1B[1m$classification\x1B[0m
                      Justification: $justification
                      Likelihood: $likelihood
                    """;
                  });
                } catch (e) {
                  // If not JSON, display the data part as-is
                  setState(() {
                    _result = dataPart;
                  });
                }
              } else {
                setState(() {
                  _result = "Error: 'data' part not found in response.";
                });
              }
            } else {
              setState(() {
                _result = "Error: Unexpected response format.";
              });
            }
          } else {
            setState(() {
              _result =
                  "Error: GET request failed (${getResponse.statusCode}).";
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
        _result = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDECEC),
      body: IndexedStack(
        index: _currentIndex, // Switch between tabs
        children: [
          const chatbot(), // Index 0 - Chatbot
          ClassificationContent(
            pickImage: _pickImage,
            image: _image,
            textController: _textController,
            onCheckMessage: _checkMessage,
            result: _result,
            onReset: _resetContent, // Pass the reset function
          ), // Index 1 - Classification page
          const Profile(), // Index 2 - Profile page
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
              // If the Home button (index 1) is clicked, go directly to Home (index 0)
              if (index == 1) {
                // Directly navigate to Home page
                _currentIndex = 0;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
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

class ClassificationContent extends StatelessWidget {
  final Future<void> Function() pickImage;
  final File? image;
  final TextEditingController textController;
  final Future<void> Function() onCheckMessage;
  final String? result;
  final VoidCallback onReset;

  const ClassificationContent({
    super.key,
    required this.pickImage,
    required this.image,
    required this.textController,
    required this.onCheckMessage,
    required this.result,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    // Notifiers for hover effects
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
          // Dismiss keyboard when tapping outside the text field
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 100,
                width: double.infinity,
                color: Color(0xFF2184FC).withOpacity(0.76),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                        boxShadow: [
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
                                    color: Color.fromARGB(255, 137, 136, 136),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0)),
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
                                        duration:
                                            const Duration(milliseconds: 200),
                                        height: hover ? 140 : 120,
                                        width: hover ? 140 : 120,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
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
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                            isCheckButtonHovered.value = true,
                                        onExit: (_) =>
                                            isCheckButtonHovered.value = false,
                                        child: ValueListenableBuilder<bool>(
                                          valueListenable: isCheckButtonPressed,
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
                                                                255,
                                                                165,
                                                                203,
                                                                248)
                                                            .withOpacity(0.85)
                                                        : const Color(
                                                                0xFF2184FC)
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
                              const SizedBox(
                                  width: 8), // Spacing between buttons
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
                                      onTap: () {
                                        // Logic for reporting the message
                                      },
                                      child: MouseRegion(
                                        onEnter: (_) =>
                                            isReportButtonHovered.value = true,
                                        onExit: (_) =>
                                            isReportButtonHovered.value = false,
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
                                                                255, 255, 0, 0)
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
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (result != null)
                            Text(
                              _extractLabel(result!),
                              textAlign: TextAlign.center,
                              style: _extractLabelStyle(result!),
                            ),
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

  String _extractLabel(String result) {
    RegExp regExp = RegExp(r"\*\*Label:\*\*\s*(\w+)");
    Match? match = regExp.firstMatch(result);
    if (match != null) {
      String label = match.group(1)?.toLowerCase() ?? "unknown";
      if (label == "spam") return "";
      if (label == "not") return "";
    }
    return "";
  }

  TextStyle _extractLabelStyle(String result) {
    String label = _extractLabel(result);
    if (label == "") {
      return const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red);
    } else if (label == "") {
      return const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green);
    } else {
      return const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black);
    }
  }
}
