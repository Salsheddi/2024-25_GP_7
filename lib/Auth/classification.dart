import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mirsad/Auth/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Classification extends StatefulWidget {
  const Classification({super.key});

  @override
  State<Classification> createState() => _ClassificationState();
}

class _ClassificationState extends State<Classification> {
  File? _image; // To store image

  // Create an instance of ImagePicker
  final ImagePicker _picker = ImagePicker();
  //for api :
  final TextEditingController _textController = TextEditingController();
  String? _result; // To store the result from the API

  // Function to pick an image
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

// api calling to Huggingface space -shdn
 Future<void> _checkMessage() async {
  String baseUrl = "https://shdnalssheddi-mirsad-classifier.hf.space/gradio_api/call/predict";

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
              String dataPart = responseBody.substring(dataIndex + 6).trim(); // Get content after "data: "
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
      _result = "Error: $e";
    });
  }
}
// end api calling code 

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDECEC),
      body: ClassificationContent(
        pickImage: _pickImage,
        image: _image,
        textController: _textController,
        onCheckMessage: _checkMessage,
        result: _result,
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

  const ClassificationContent({
    super.key,
    required this.pickImage,
    required this.image,
    required this.textController,
    required this.onCheckMessage,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDECEC),
      resizeToAvoidBottomInset: true, // Prevent overflow when keyboard appears
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside the text field
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                height: 100,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2184FC),
                      Color(0xFFA4E2EC),
                    ],
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black54, // Dark background for the home button
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.home, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Mirsad's Fraud Detector",
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Input Card
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Got a suspicious message? Let’s find out if it’s legitimate or a fraud!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: textController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Enter text here...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                              fillColor: Colors.grey[200],
                              filled: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('OR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                          const Text('Upload screenshot of the message'),
                          const SizedBox(height: 16),
                          IconButton(
                            onPressed: pickImage,
                            icon: Icon(Icons.image, size: 40, color: Colors.blue.withOpacity(0.65)),
                          ),
                          image != null
                              ? Image.file(image!, height: 150, width: 150, fit: BoxFit.cover)
                              : const SizedBox(height: 16),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              // Call the _checkMessage function when the button is pressed
                              await onCheckMessage();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2184FC).withOpacity(0.65),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),
                            child: const Text('Check Message', style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                          const SizedBox(height: 16),
                          // Display only the label (e.g., SPAM or NOT SPAM) with dynamic styling
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

  // Function to extract the label (e.g., SPAM or NOT SPAM)
  String _extractLabel(String result) {
    RegExp regExp = RegExp(r"\*\*Label:\*\*\s*(\w+)");
    Match? match = regExp.firstMatch(result);
    if (match != null) {
      String label = match.group(1)?.toLowerCase() ?? "unknown";
      if (label == "spam") return "SPAM";
      if (label == "not") return "NOT SPAM"; // Map "not" to "NOT SPAM"
    }
    return "Unknown";
  }

  // Function to extract the label's style based on its value
  TextStyle _extractLabelStyle(String result) {
    String label = _extractLabel(result);
    if (label == "SPAM") {
      return const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red);
    } else if (label == "NOT SPAM") {
      return const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green);
    } else {
      return const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black);
    }
  }
}
