import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mirsad/Auth/SignUp.dart';
import 'package:mirsad/Auth/ResetPass.dart'; 

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for the form fields
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Function to show loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
  }

  // Function to show pop-up messages
  void _showPopUpMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Invalid Input"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  // Function to handle login
  void _logIn() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Check for empty fields
    if (email.isEmpty || password.isEmpty) {
      _showPopUpMessage(context, 'Please fill all fields');
      return;
    }

    // Check for valid email format
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showPopUpMessage(context, 'Please enter a valid email address');
      return;
    }

    _showLoadingDialog(context);

    try {
      // Sign in the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the user exists in Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (userDoc.exists) {
        Navigator.pop(context);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUp())); // Replace with Home or Profile
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login successful!')));
      } else {
        Navigator.pop(context);
        _showPopUpMessage(context, 'Incorrect Email/Password');
      }
    } catch (e) {
      Navigator.pop(context);

      // Handle Firebase authentication exceptions
      if (e is FirebaseAuthException) {
        if (e.code == 'wrong-password' || e.code == 'user-not-found') {
          _showPopUpMessage(context, 'Incorrect Email/Password');
        } else {
          _showPopUpMessage(context, 'Incorrect Email/Password.');
        }
      } else {
        _showPopUpMessage(context, 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1D76E2), // #1D76E2
              Color(0xFF2184FC), // #2184FC
              Color(0xFF4D9CFC), // #4D9CFC
              Color(0xFF7DB4F6), // #7DB4F6
              Color(0xFFC1DDFF), // #C1DDFF
              Color(0xFFD9D9D9), // #D9D9D9
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 50), // padding above logo
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(70),
                  color: Colors.white.withOpacity(0.75),
                ),
                child: Image.asset('img/Mirsad2.png'),
              ),
              SizedBox(height: 20),
              Text(
                'Your First Line In Defense Against Smishing',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 30),

              // Form fields
              TextFormField(
                controller: emailController, // Updated to usernameController
                decoration: InputDecoration(
                  hintText: 'E-mail', // Changed hint text to Username
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.83),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.28),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.83),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.28),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                obscureText: true, // For password security
              ),
              SizedBox(height: 25),
                                   // Forget your password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ResetPass()), // Navigate to ResetPass
                        );
                      },
                      child: const Text(
                        'Forget your password?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

              // Login button
              MaterialButton(
                height: 53,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.0),
                ),
                color: Color(0xFF1C7ECE),
                child: Text(
                  'Log In',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: _logIn,
              ),
              SizedBox(height: 25),

              // No account?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUp()));
                    },
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }
}
