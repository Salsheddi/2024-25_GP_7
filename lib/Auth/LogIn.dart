import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? emailErrorMessage;
  String? passwordErrorMessage;

  void _logIn() async {
    setState(() {
      emailErrorMessage = null;
      passwordErrorMessage = null;
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty) {
      setState(() {
        emailErrorMessage = "Email cannot be empty";
      });
      return;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() {
        emailErrorMessage = "Please enter a valid email address";
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        passwordErrorMessage = "Password cannot be empty";
      });
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      Navigator.of(context).pop();

      if (userDoc.exists) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Profile()));
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Login successful!')));
      } else {
        setState(() {
          emailErrorMessage = "              ";
          passwordErrorMessage = "Email or password is incorrect";
        });
      }
    } catch (e) {
      Navigator.of(context).pop();
      setState(() {
        emailErrorMessage = "                   ";
        passwordErrorMessage = "Email or password is incorrect";
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
              SizedBox(height: 30),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 100,
                  width: 100, // Set a fixed width
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(70),
                    color: Colors.white.withOpacity(0.75),
                  ),
                  child: Image.asset(
                    'img/Mirsad2.png',
                  ),
                ),
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
             Row(
               children: [
                 Text("E-mail", style: TextStyle(color: Colors.white)),
                 Text(" *", style: TextStyle(color: Colors.red)),
                 ],
              ),
              TextFormField(
                controller: emailController,
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      emailErrorMessage = "Email cannot be empty";
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      emailErrorMessage = "Please enter a valid email address";
                    } else {
                      emailErrorMessage = null; // Clear the error
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: 'E-mail',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 145, 143, 143),
                    fontSize: 15,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.28),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0),
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  errorText: emailErrorMessage,
                ),
              ),
              SizedBox(height: 15),

              // Password Form field
              Row(
               children: [
                 Text("Password", style: TextStyle(color: Colors.white)),
                 Text(" *", style: TextStyle(color: Colors.red)),
                 ],
              ),
              TextFormField(
                controller: passwordController,
                onChanged: (value) {
                  // Validate password on change
                  setState(() {
                    if (value.isEmpty) {
                      passwordErrorMessage = "Password cannot be empty";
                    } else {
                      passwordErrorMessage = null; // Clear the error
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 145, 143, 143),
                    fontSize: 15,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.28),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  errorText: passwordErrorMessage,
                ),
                obscureText: true,
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
                    style: (TextStyle(color: Colors.white)),
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
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onPressed: () {
                  // Validate the form
                  if (_formKey.currentState!.validate()) {
                    _logIn();
                  } else {
                    // If the form is invalid, display an error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Something went wrong please try again.')),
                    );
                  }
                },
              ),
              const SizedBox(height: 15),

              // Go to Sign Up screen
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don’t have an account? ',
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUp()),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color(0xFF2184FC),
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
    );
  }
}
