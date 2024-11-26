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
  TextEditingController reenterEmailController = TextEditingController();
  bool hasError = false; // Flag to track if there's an error
  bool emailMismatch = false; // Flag for email mismatch

  // Function to send the reset email
  Future<void> _sendResetEmail(BuildContext context) async {
    String email = emailController.text.trim();

    // Validate email format
    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Check if the email exists in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userDoc.docs.isEmpty) {
        throw Exception('No user found with this email');
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Navigator.pop(context);

      setState(() {
        hasError = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent to $email')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LogIn()),
      );
    } catch (e) {
      Navigator.pop(context);
      setState(() {
        hasError = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user found with this email')),
      );
    }
  }

  // Function to check if emails match
  void _checkEmailMatch() {
    setState(() {
      emailMismatch = emailController.text != reenterEmailController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'img/auth.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              children: [
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
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                              Row(
                               children: [
                                   Text("E-mail", style: TextStyle(color: Colors.white)),
                                   Text(" *", style: TextStyle(color: Colors.red)),
                                   ],
                                ),
                              TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: '',
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.3),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: hasError ? Colors.red : Colors.white,
                                      width: 2.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: hasError ? Colors.red : Colors.white,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                                onChanged: (value) {
                                  _checkEmailMatch();
                                },
                              ),
                              SizedBox(height: 20),
                              Row(
                               children: [
                                   Text("Re-enter E-mail", style: TextStyle(color: Colors.white)),
                                   Text(" *", style: TextStyle(color: Colors.red)),
                                   ],
                                ),
                              TextField(
                                controller: reenterEmailController,
                                decoration: InputDecoration(
                                  labelText: '',
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.3),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: emailMismatch ? Colors.red : Colors.white,
                                      width: 2.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: emailMismatch ? Colors.red : Colors.white,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                                onChanged: (value) {
                                  _checkEmailMatch();
                                },
                              ),
                              if (emailMismatch)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Emails do not match',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: emailMismatch
                                    ? null
                                    : () {
                                        _sendResetEmail(context);
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
