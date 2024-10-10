import 'package:flutter/material.dart';
import 'newPass.dart';

class OTPveri extends StatelessWidget {
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
                        'OTP Verification',
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
                        // Semi-transparent background box for text and OTP field
                        Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Please enter the 6-digit verification code sent to your email.',
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
                              // OTP input field
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Enter OTP',
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.3), // Slight background color
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              SizedBox(height: 20),
                              // Resend OTP link
                              TextButton(
                                onPressed: () {
                                  // Resend OTP functionality
                                },
                                child: Text(
                                  'Didn\'t receive code? Resend Now',
                                  style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                                ),
                              ),
                              SizedBox(height: 20),
                              // Proceed button
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => newPass()),
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