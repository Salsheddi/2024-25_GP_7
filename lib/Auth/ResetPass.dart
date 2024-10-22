// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mirsad/Auth/LogIn.dart';

class ResetPass extends StatefulWidget {
  @override
  _ResetPassState createState() => _ResetPassState();
}

class _ResetPassState extends State<ResetPass> {
  TextEditingController emailController = TextEditingController();
  bool hasError = false; // Flag to track if there's an error

  // Function to send the reset email
  Future<void> _sendResetEmail(BuildContext context) async {
  String email = emailController.text.trim();

  // Step 1: Validate email format
  if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
    // Show error message for invalid format
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter a valid email address')),
    );
    return; // Exit the function early
  }

  // Show loading spinner
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Center(
        child: CircularProgressIndicator(),
      );
    },
  );

  try {
    // Step 2: Check if the email exists in Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users') // Change this to your users collection
        .where('email', isEqualTo: email)
        .get();

    // Check if user document exists
    if (userDoc.docs.isEmpty) {
      throw Exception('No user found with this email');
    }

    // Send the reset password email
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

    // Dismiss the loading spinner
    Navigator.pop(context);

    // Reset error flag if successful
    setState(() {
      hasError = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password reset email sent to $email')),
    );

    // Navigate to the login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LogIn()),
    );
  } catch (e) {
    // Dismiss the loading spinner
    Navigator.pop(context);

    // Set the error flag to true
    setState(() {
      hasError = true;
    });

    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('please fill the field')), // Show specific error message
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with transparency
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'img/auth.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Positioned.fill(
            child: Column(
              children: [
                // White bar for navigation
                Container(
                  color: Colors.white,
                  child: SafeArea(
                    child: AppBar(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      title: Text(
                        'Reset Your Password',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ),
                // Main content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Semi-transparent background box for text and email field
                        Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Please enter your registered email and we will send a link to reset your password.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0,
                                      color: Colors.black.withOpacity(0.5),
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              // Email input field
                              TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.3),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: hasError ? Colors.red : Colors.white, // Red border on error
                                      width: 2.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: hasError ? Colors.red : Colors.white,
                                      width: 2.0,
                                    ),
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                              SizedBox(height: 20),
                              // Proceed button
                              ElevatedButton(
                                onPressed: () {
                                  _sendResetEmail(context); // Call the function to reset password
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  minimumSize: const Size(200, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Proceed',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
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
          ),
        ],
      ),
    );
  }
}
