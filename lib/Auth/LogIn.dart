// ignore_for_file: unused_import

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirsad/Auth/ResetPass.dart';
import 'package:mirsad/Auth/SignUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  @override
  // Controllers to handle input
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance

  // Function to show error messages
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white))),
    );
  }

  // Function to handle login logic
  Future<void> _handleLogin() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showErrorMessage("None of the fields can be empty");
      return;
    }

    try {
      // Firebase login logic
      // ignore: unused_local_variable
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: username,
        password: password,
      );
      // If login is successful, navigate to the next page or show a success message
      _showErrorMessage("Login successful!");

      // Redirect user to the main app page
      // Navigator.pushReplacementNamed(context, '/home'); // Define the route to home if needed
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showErrorMessage(
            "Incorrect username/password."); // security measure not to mention what went wrong
      } else if (e.code == 'wrong-password') {
        _showErrorMessage("Incorrect username/password.");
      } else {
        _showErrorMessage(e.message ?? "An error occurred.");
      }
    }
  }

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
      child: ListView(children: [
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            height: 50,
          ), // padding above logo
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(70),
              color: Colors.white.withOpacity(0.75),
            ),
            child: Image.asset(
              'img/Mirsad2.png',
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

          //Form
          TextFormField(
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
                )),
          ),

          SizedBox(height: 15),

          TextFormField(
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
                )),
          ),

          SizedBox(height: 25),
        ]),

        // Forget your password link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ResetPass()), // Navigate to ResetPass
              );
            },
            child: const Text(
              'Forget your password?',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // log in button
        MaterialButton(
          height: 53,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          color: Colors.white,
          onPressed: () {},
          child: Text(
            "Log in",
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Freeman',
              color: Color(0xFF1D76E2),
            ),
          ),
        ),

        //text under button
        SizedBox(height: 35),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "You don't have an acount? ",
              style: TextStyle(color: Colors.white),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const SignUp()), // Navigate to SignUp page
                );
              },
              child: const Text(
                "Sign Up now!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ]),
    ));
  }
}
