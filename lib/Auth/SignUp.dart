import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:mirsad/Auth/LogIn.dart';
import 'package:mirsad/Auth/Profile.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController reenterPasswordController = TextEditingController();

  // Variables for form validation
  bool isPasswordValid = true;
  bool isReenteredPasswordMatching = true;
  bool isEmailValid = true;
  bool isUsernameValid = true;

  final _formKey = GlobalKey<FormState>();

  // Track user interactions
  bool hasUserInteractedWithUsername = false;
  bool hasUserInteractedWithEmail = false;
  bool hasUserInteractedWithPassword = false;
  bool hasUserInteractedWithReenterPassword = false;
  
  String emailErrorMessage = "";

  // Function to validate email
  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // Function to hash the password
  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // Function to validate the password structure
  bool validatePasswordStructure(String password) {
    String pattern = r'^(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(password);
  }

  // Update validation status when typing
  void updateValidation() {
    setState(() {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      String reenteredPassword = reenterPasswordController.text.trim();

      if (hasUserInteractedWithUsername) {
        isUsernameValid = usernameController.text.isNotEmpty;
      }
      if (hasUserInteractedWithPassword) {
        isPasswordValid = validatePasswordStructure(password);
      }
      if (hasUserInteractedWithReenterPassword) {
        isReenteredPasswordMatching = password == reenteredPassword;
      }
      if (hasUserInteractedWithEmail) {
        isEmailValid = isValidEmail(email);
        if (!isEmailValid && emailErrorMessage.isEmpty) {
          emailErrorMessage = 'Please enter a valid email';
        }
      }
    });
  }

  // Loading dialog function
  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  // Function to handle sign-up logic
  Future<void> _signUp() async {
  // Check if all fields are valid
  if (usernameController.text.trim().isEmpty) {
    setState(() {
      isUsernameValid = false;
    });
    return; // Stop the signup process
  } else {
    setState(() {
      isUsernameValid = true; // Username is valid if it is not empty
    });
  }

  if (isUsernameValid && isEmailValid && isPasswordValid && isReenteredPasswordMatching) {
    showLoadingDialog(); // Show loading dialog when sign-up starts
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
      });

      Navigator.pop(context); // Close the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign-up successful!')));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Profile()));
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close the loading dialog
      if (e.code == 'email-already-in-use') {
        setState(() {
          isEmailValid = false;
          emailErrorMessage = 'This email is already taken';
        });
      } else if (e.code == 'invalid-email') {
        setState(() {
          isEmailValid = false;
          emailErrorMessage = 'Please enter a valid email';
        });
      } else {
        setState(() {
          emailErrorMessage = 'An unknown error occurred';
        });
      }
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
              Color(0xFF1D76E2),
              Color(0xFF2184FC),
              Color(0xFF4D9CFC),
              Color(0xFF7DB4F6),
              Color(0xFFC1DDFF),
              Color(0xFFC1DDF3),
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 30),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
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

              // Username field
              Text("Username", style: TextStyle(color: Colors.white)),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: 'Enter your username',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 145, 143, 143),
                    fontSize: 15,
                  ),
                  errorText: hasUserInteractedWithUsername && !isUsernameValid
                      ? "Username can't be empty"
                      : null,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.28),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0),
                    borderSide: BorderSide(
                        color: isUsernameValid ? Colors.white : Colors.red),
                  ),
                ),
                onChanged: (_) {
                  hasUserInteractedWithUsername = true;
                  updateValidation();
                }, // Revalidate while typing
              ),
              SizedBox(height: 15),

              // Email field
              Text("E-mail", style: TextStyle(color: Colors.white)),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 145, 143, 143),
                    fontSize: 15,
                  ),
                  errorText: hasUserInteractedWithEmail && !isEmailValid
                      ? emailErrorMessage
                      : null,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.28),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0),
                    borderSide: BorderSide(
                        color: isEmailValid ? Colors.white : Colors.red),
                  ),
                ),
                onChanged: (_) {
                  hasUserInteractedWithEmail = true;
                  updateValidation();
                }, // Revalidate while typing
              ),

              SizedBox(height: 15),

              // Password field
              Text("Password", style: TextStyle(color: Colors.white)),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: 'At least 8 characters, includes number and symbol',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 145, 143, 143),
                    fontSize: 13,
                    overflow: TextOverflow.ellipsis,
                  ),
                  errorText: hasUserInteractedWithPassword && !isPasswordValid
                      ? "8+ characters, must include number & symbol"
                      : null,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.28),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0),
                    borderSide: BorderSide(
                        color: isPasswordValid ? Colors.white : Colors.red),
                  ),
                ),
                obscureText: true,
                onChanged: (_) {
                  hasUserInteractedWithPassword = true;
                  updateValidation();
                }, // Revalidate while typing
              ),

              SizedBox(height: 15),

              // Re-enter Password field
              Text("Re-enter Password", style: TextStyle(color: Colors.white)),
              TextFormField(
                controller: reenterPasswordController,
                decoration: InputDecoration(
                  hintText: 'Re-enter your password',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 145, 143, 143),
                    fontSize: 15,
                  ),
                  errorText: hasUserInteractedWithReenterPassword &&
                          !isReenteredPasswordMatching
                      ? "Passwords do not match"
                      : null,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.28),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0),
                    borderSide: BorderSide(
                        color: isReenteredPasswordMatching
                            ? Colors.white
                            : Colors.red),
                  ),
                ),
                obscureText: true,
                onChanged: (_) {
                  hasUserInteractedWithReenterPassword = true;
                  updateValidation();
                }, // Revalidate while typing
              ),

              SizedBox(height: 30),

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
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
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
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2184FC),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


