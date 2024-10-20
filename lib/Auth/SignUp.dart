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

  // Function to show loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
  }

  void _signUp() async {
  String username = usernameController.text.trim();
  String email = emailController.text.trim();
  String password = passwordController.text.trim();
  String reenteredPassword = reenterPasswordController.text.trim();

  // Validate form inputs
  setState(() {
    isUsernameValid = username.isNotEmpty;
    isEmailValid = isValidEmail(email); // Validate format
    isPasswordValid = validatePasswordStructure(password);
    isReenteredPasswordMatching = password == reenteredPassword;
  });

  // Check if any of the fields are invalid
  if (!isUsernameValid || !isEmailValid || !isPasswordValid || !isReenteredPasswordMatching) {
    return; // If there are validation issues, exit without trying to sign up
  }

  try {
    _showLoadingDialog(context);

    // Check if the email is already in use via FirebaseAuth
    List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(email);
    if (signInMethods.isNotEmpty) {
      // Email is already in use
      setState(() {
        isEmailValid = false; // Mark email as invalid to trigger the red outline
      });
      Navigator.pop(context); // Close the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Email is already in use. Please choose another.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Proceed with user creation if email is valid and not in use
    String hashedPassword = hashPassword(password);
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    // Save user information in Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'uid': userCredential.user!.uid,
      'username': username,
      'email': email,
      'password': hashedPassword,
    });

    Navigator.pop(context); // Close the loading dialog
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Sign-up successful!')));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Profile()));
  } catch (e) {
    Navigator.pop(context);
    // Handle other error cases if needed
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('An error occurred. Please try again later.'),
      backgroundColor: Colors.red,
    ));
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
              Color(0xFFD9D9D9),
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
                  errorText: isUsernameValid ? null : "Username can't be empty",
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
      borderSide: BorderSide(
                        color: isUsernameValid ? Colors.white : Colors.red),
                  ),
                ),
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
    errorText: isEmailValid ? null : "This email is already taken or invalid",
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
      borderSide: BorderSide(
        color: isEmailValid ? Colors.white : Colors.red, // Change to red if invalid when focused
      ),
    ),
  ),
),
              SizedBox(height: 15),

              // Password field
              Text("Password", style: TextStyle(color: Colors.white)),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: 'password at least 8 letters includes (number,special character)',
                   hintStyle: TextStyle(
                   color: Color.fromARGB(255, 145, 143, 143),
                    fontSize: 15,
                    ), 
                  errorText: isPasswordValid
                      ? null
                      : "Password must be at least 8 characters long, contain a number and a symbol",
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
      borderSide: BorderSide(
                        color: isPasswordValid ? Colors.white : Colors.red,),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 15),

              // Re-enter password field
              Text("Re-enter Password", style: TextStyle(color: Colors.white)),
              TextFormField(
                controller: reenterPasswordController,
                decoration: InputDecoration(
                  hintText: 'Re-enter your password',
                   hintStyle: TextStyle(
                   color: Color.fromARGB(255, 145, 143, 143),
                    fontSize: 15,
                    ), 
                  errorText: isReenteredPasswordMatching
                      ? null
                      : "Passwords do not match",
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
      borderSide: BorderSide(
                        color: isReenteredPasswordMatching
                            ? Colors.white : Colors.red),
                  ),
                ),
                obscureText: true,
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
                      color: Colors.white.withOpacity(0.8), 
                      fontWeight: FontWeight.bold, 
                      fontSize: 13, 
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => const LogIn()));
                    },
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        color: Color(0xFF2184FC),
                        fontWeight: FontWeight.bold, 
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
