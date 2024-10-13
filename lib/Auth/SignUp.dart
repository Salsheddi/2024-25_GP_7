// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart'; // For hashing the password
import 'dart:convert'; // For utf8.encode
import 'package:mirsad/Auth/LogIn.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for the form fields
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Function to validate phone number
  bool isValidPhoneNumber(String phoneNumber) {
    return phoneNumber.startsWith('05') &&
        phoneNumber.length == 10 &&
        RegExp(r'^[0-9]+$').hasMatch(phoneNumber);
  }

  // Function to hash the password
  String hashPassword(String password) {
    var bytes = utf8.encode(password); // Convert the password to bytes
    return sha256.convert(bytes).toString(); // Hash the password using SHA256
  }

  // Function to show loading dialog to prevent user from altering the info while storing
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
  }

  // Function to check if the username and email are unique
  Future<bool> isUnique(String username, String email) async {
    QuerySnapshot usernameSnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    QuerySnapshot emailSnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (usernameSnapshot.docs.isNotEmpty || emailSnapshot.docs.isNotEmpty) {
      return false; // Username or email is already taken
    }
    return true;
  }

  // Function to handle sign-up
  void _signUp() async {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();

    // Check if any field is empty
    if (username.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    // Validate phone number
    if (!isValidPhoneNumber(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Phone number must start with 05 and be 10 digits long')));
      return;
    }

    // Check if username and email are unique
    _showLoadingDialog(context); // Show loading dialog
    bool unique = await isUnique(username, email);
    Navigator.pop(context); // Close loading dialog

    if (!unique) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Username or Email is already taken')));
      return;
    }

    // If all validations pass, hash the password and store the data
    try {
      _showLoadingDialog(
          context); // Show loading dialog during the sign-up process
      String hashedPassword = hashPassword(password);

      // Store user data in Firebase Authentication and Firestore
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'phone': phone,
        'password': hashedPassword, // Store hashed password
      });

      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sign-up successful!')));

      // Navigate to login or home page
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const LogIn())); // should be homepage
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
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

              //Form fields
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: 'Username',
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
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'E-mail',
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
                controller: phoneController,
                decoration: InputDecoration(
                  hintText: 'Phone Number',
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

              // Sign up button
              MaterialButton(
                height: 53,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.0),
                ),
                color: Color(0xFF1C7ECE),
                child: Text(
                  'Sign Up',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: _signUp,
              ),
              SizedBox(height: 25),

              // Already have an account?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
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
                              builder: (context) => const LogIn()));
                    },
                    child: Text(
                      'Log in',
                      style: TextStyle(
                        color: Color(0xFFB1D6FD),
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
