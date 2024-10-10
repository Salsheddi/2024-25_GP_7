import 'package:flutter/material.dart';
import 'resetSuccess.dart';

class newPass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

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
                        // Semi-transparent box for password input fields
                        Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              // New Password field
                              TextField(
                                controller: newPasswordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'New Password',
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.3), // Slight background color for text field
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                                  ),
                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                              SizedBox(height: 20),
                              // Confirm Password field
                              TextField(
                                controller: confirmPasswordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.3), // Slight background color
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                                  ),
                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                              SizedBox(height: 20),
                              // Reset Password button
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => resetSuccess()),
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
