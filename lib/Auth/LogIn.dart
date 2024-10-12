import 'package:flutter/material.dart';
import 'ResetPass.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Controllers to handle input
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
        child: Stack(
          children: <Widget>[
            // Positioned Back Button
            Positioned(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // To go back to the previous screen
                },
              ),
            ),

            // Main Content: Logo, Fields, and Buttons
            Center(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                children: <Widget>[
                  Column(
                    children: [
                      const SizedBox(
                          height: 60), // Spacing below the back button

                      // Circular Logo Section
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
                    ],
                  ),

                  // Username TextField
                  TextField(
                    controller: _usernameController,
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
                  const SizedBox(height: 20),

                  // Password TextField
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.28),
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.83),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13.0),
                          borderSide: BorderSide.none,
                        )),
                  ),
                  const SizedBox(height: 20),

                  // Forget your password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ResetPass()), // Navigate to ResetPass
                        );
                      },
                      child: const Text(
                        'Forget your password?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Log in Button
                  SizedBox(
                    width: double.infinity,
                    height: 53,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF1D76E2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      onPressed: () {
                        // Add your login logic here
                      },
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "Don't you have an account?",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to the signup page
                        },
                        child: const Text(
                          'Sign up now!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
