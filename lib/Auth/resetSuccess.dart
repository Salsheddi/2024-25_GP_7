import 'package:flutter/material.dart';

class resetSuccess extends StatelessWidget {
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
                'img/auth.jpg', // Same background as ResetPass
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content with a container for better visibility
          Center(
            child: Container(
              padding: EdgeInsets.all(24.0), // Padding for spacing inside the container
              margin: EdgeInsets.symmetric(horizontal: 16.0), // Margin to keep the container centered
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7), // Slightly transparent background for contrast
                borderRadius: BorderRadius.circular(10), // Rounded corners for a modern look
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lock icon with color and size
                  Icon(
                    Icons.lock,
                    size: 100,
                    color: Colors.white, // White icon to stand out
                  ),
                  SizedBox(height: 20),
                  // Success message
                  Text(
                    'Reset Password Successful!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text for consistency
                    ),
                  ),
                  SizedBox(height: 20),
                  // Sub-message
                  Text(
                    'Please wait... You will be directed to the homepage soon.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // White text for clarity
                    ),
                  ),
                  SizedBox(height: 40),
                  // Circular progress indicator
                  CircularProgressIndicator(
                    color: Colors.blueAccent, // Consistent with the app's primary color
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


