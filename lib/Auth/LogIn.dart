import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mirsad/Auth/Profile.dart';
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

  // Variables to store error messages
  String? emailErrorMessage;
  String? passwordErrorMessage;

  // Function to handle login
  void _logIn() async {
    setState(() {
      emailErrorMessage = null;
      passwordErrorMessage = null;
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Check for empty fields and set error messages
    if (email.isEmpty) {
      setState(() {
        emailErrorMessage = "Email cannot be empty";
      });
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() {
        emailErrorMessage = "Please enter a valid email address";
      });
    }

    if (password.isEmpty) {
      setState(() {
        passwordErrorMessage = "Password cannot be empty";
      });
    }

    // If there are errors, return early
    if (emailErrorMessage != null || passwordErrorMessage != null) return;

    try {
      // Sign in the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the user exists in Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (userDoc.exists) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Profile())); // Replace with Home or Profile
      } else {
        setState(() {
          emailErrorMessage = "Email or password is incorrect";
          passwordErrorMessage = "Email or password is incorrect";
        });
      }
    } catch (e) {
      setState(() {
        emailErrorMessage = "Failed to log in. Check your credentials.";
        passwordErrorMessage = "Failed to log in. Check your credentials.";
      });
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
              SizedBox(height: 30), // padding above logo
              Container(
                height: 100,
                width: 100,
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

              // Email Form field
              Text("E-mail", style: TextStyle(color: Colors.white)),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'E-mail',
                  hintStyle: TextStyle(
                   color: Color.fromARGB(255, 145, 143, 143),
                    fontSize: 15,
                    ),
                  contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.28),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13.0),
      borderSide: BorderSide(
        color: Colors.white, // Set default enabled border color to white
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13.0),
      borderSide: BorderSide(color: Colors.white), // Default border color white
                  ),
                  errorText: emailErrorMessage, // Show error message
                ),
              ),
              SizedBox(height: 15),

              // Password Form field
              Text("Password", style: TextStyle(color: Colors.white)),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(
                   color: Color.fromARGB(255, 145, 143, 143),
                    fontSize: 15,
                    ),
                  contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.28),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13.0),
      borderSide: BorderSide(
        color: Colors.white, // Set default enabled border color to white
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13.0),
      borderSide: BorderSide(color: Colors.white), // Default border color white
                  ),
                  errorText: passwordErrorMessage, // Show error message
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
                      MaterialPageRoute(builder: (context) => ResetPass()),
                    );
                  },
                  child: const Text(
                    'Forget your password?',
                    style: (TextStyle(color: Colors.white)
                    ),  
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (context) => const SignUp()));
                    },
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: Color(0xFF2184FC),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
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
