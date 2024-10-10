import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'Auth/LogIn.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mirsad', 
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(), // Set MainPage as the initial route
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF), // Start color
              Color(0xFFFFFFFF), // End color
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                "img/Mirsad2.png", // Ensure this is the correct path to your logo image
                width: 100, // Adjust width as needed
                height: 100, // Adjust height as needed
              ),
              const SizedBox(height: 20), // Space between logo and text
              const Text(
                'Your First Line In Defense Against Smishing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0), // Text color
                ),
                textAlign: TextAlign.center, // Center the text
              ),
              const SizedBox(height: 40), // Space between text and buttons
              
              // Sign Up Button
              ElevatedButton(
                onPressed: () {
                  // Add sign-up navigation logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D76E2), // Background color set to #1D76E2
                  minimumSize: const Size(200, 50), // Button size
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                ),
                child: const Text(
                  'Sign Up', 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Text color
                ),
              ),
              const SizedBox(height: 20), // Space between buttons
              
              // Log In Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()), // Navigate to LogIn page
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D76E2), // Background color set to #1D76E2
                  minimumSize: const Size(200, 50), // Button size
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

