import 'package:flutter/material.dart';
import 'OTPveri.dart';

class ResetPass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();

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
                        // Semi-transparent background box for text and email field
                        Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5), // Semi-transparent background
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Please enter your registered E-mail & we will send an OTP verification code to reset your password.',
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
                              // Email input field
                              TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: 'E-mail',
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => OTPveri()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 255, 255, 255), // Background color set to #1D76E2
                  minimumSize: const Size(200, 50), // Button size
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                ),
                                child: Text('Proceed',
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
