import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mirsad/Auth/LogIn.dart';

class ResetPass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();

    // Function to send the reset email after fetching the email by username
    Future<void> _sendResetEmailByUsername(BuildContext context) async {
      String username = usernameController.text.trim();

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
        // Firestore query to get the email by username
        CollectionReference users = FirebaseFirestore.instance.collection('users'); // Replace 'users' with your collection name

        QuerySnapshot querySnapshot = await users.where('username', isEqualTo: username).get();

        if (querySnapshot.docs.isNotEmpty) {
          String email = querySnapshot.docs[0]['email']; // Assuming 'email' is a field in your user document
          
          // Send the reset password email
          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

          // Dismiss the loading spinner
          Navigator.pop(context);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password reset email sent to $email')),
          );

          // Navigate to the OTP verification page or login page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LogIn()),
          );
        } else {
          // Dismiss the loading spinner
          Navigator.pop(context);

          // Show error message if username is not found
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Username not found')),
          );
        }
      } catch (e) {
        // Dismiss the loading spinner
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background image with transparency
          Positioned.fill(
            child: Opacity(
              opacity: 0.5, // Adjust the transparency as needed
              child: Image.asset(
                'img/auth.jpg', // Your background image path
                fit: BoxFit.cover, // Ensures the image covers the entire background
              ),
            ),
          ),
          // Content
          Positioned.fill(
            child: Column(
              children: [
                // White bar for navigation
                Container(
                  color: Colors.white, // White background for the app bar area
                  child: SafeArea(
                    child: AppBar(
                      backgroundColor: Colors.white, // White bar background
                      elevation: 0, // No shadow
                      title: Text(
                        'Reset Your Password',
                        style: TextStyle(
                          color: Colors.black, // Black text for contrast
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black), // Black back icon for contrast
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
                        // Semi-transparent background box for text and username field
                        Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5), // Semi-transparent background
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Please enter your registered Username & we will send a link to reset your password.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white, // Text color white for visibility
                                  fontWeight: FontWeight.bold, // Bold text
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0,
                                      color: Colors.black.withOpacity(0.5), // Slight shadow for contrast
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              // Username input field
                              TextField(
                                controller: usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0, // Increase label font size
                                  ),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.3), // Slight background color to stand out
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white, // White border
                                      width: 2.0, // Bold border width
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white, // White border when focused
                                      width: 2.0, // Bold border width
                                    ),
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold, // Bold input text
                                  fontSize: 18.0, // Increase input text size
                                ),
                              ),
                              SizedBox(height: 20),
                              // Proceed button
                              ElevatedButton(
                                onPressed: () {
                                  _sendResetEmailByUsername(context); // Call the function to reset password
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white, // Button color
                                  minimumSize: const Size(200, 50), // Button size
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8), // Rounded corners
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