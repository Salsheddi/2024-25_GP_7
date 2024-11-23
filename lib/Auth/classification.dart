import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mirsad/Auth/home.dart';

class Classification extends StatefulWidget {
  const Classification({super.key});

  @override
  State<Classification> createState() => _ClassificationState();
}

class _ClassificationState extends State<Classification> {
  File? _image; // To store image

  // Create an instance of ImagePicker
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDECEC),
      body: ClassificationContent(
        pickImage: _pickImage,
        image: _image,
      ),
    );
  }
}

class ClassificationContent extends StatelessWidget {
  final Future<void> Function() pickImage;
  final File? image;

  const ClassificationContent({
    super.key,
    required this.pickImage,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDECEC), 
      body: Column(
        children: [
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
                const SizedBox(width: 10), // Add spacing before the home button
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1565C0), // Darker background for the home button
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Home()),
                      );
                    },
                    icon: const Icon(Icons.home, color: Colors.white),
                    iconSize: 24,
                    splashColor: Colors.transparent, // Remove splash effect
                    highlightColor: Colors.transparent, // Remove highlight effect
                  ),
                ),
                const SizedBox(width: 10), // Spacing between the home button and title
                const Expanded(
                  child: Text(
                    "Mirsad's Fraud Detector",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main content of the screen
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Card for the main content
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'Got a suspicious message? Let’s find out if it’s legitimate or a fraud!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        // Text field for entering text
                        TextField(
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Enter text here...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            fillColor: Colors.grey[200],
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'upload screenshot of the message',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 16),
                        // Image upload button
                        IconButton(
                          onPressed: pickImage,
                          icon: Icon(
                            Icons.image,
                            size: 40,
                            color: const Color(0xFF2184FC).withOpacity(0.65),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Display selected image or message
                        image != null
                            ? Image.file(
                                image!,
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              )
                            : const SizedBox(height: 16),
                        // Submit button
                        ElevatedButton(
                          onPressed: () {
                            // Backend function should be here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2184FC).withOpacity(0.65),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text(
                            'Check Message',
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
    );
  }
}

