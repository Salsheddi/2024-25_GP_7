// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mirsad/Auth/SignUp.dart';
import 'package:mirsad/Auth/LogIn.dart';
import 'package:mirsad/Auth/classification.dart';
import 'package:mirsad/Auth/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized first
  await dotenv.load(); // Load environment variables
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp()); // Run the app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
      body: Stack(
        children: [
          // Background image positioned only behind the buttons
          Positioned(
            bottom: 0, // Position the background image at the bottom
            left: 0,
            right: 0,
            child: Container(
              height: 600, // Adjust this height to cover only the button area
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      "img/main_page.png"), // Path to your background image
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Main content container (logo, text, buttons)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  "img/Mirsad2.png", // Ensure this is the correct path to your logo image
                  width: 200, // Adjust width as needed
                  height: 200, // Adjust height as needed
                ),
                Text(
                  'MIRSAD',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0), // Text color
                  ),
                  textAlign: TextAlign.center,
                ), // Center the text
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
                const SizedBox(height: 250), // Space between text and buttons

                // Sign Up Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const SignUp()), // Navigate to SignUp page
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.white, // White background for button
                    minimumSize: const Size(200, 50), // Button size
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                    ),
                    side: BorderSide(
                        color: Colors.blue,
                        width: 2), // Optional: Border to make it stand out
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Color(0xFF1D76E2), // Blue text
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Space between buttons

                // Log In Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const LogIn()), // Navigate to LogIn page
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.white, // White background for button
                    minimumSize: const Size(200, 50), // Button size
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                    ),
                    side: BorderSide(
                        color: Colors.blue,
                        width: 2), // Optional: Border to make it stand out
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      color: Color(0xFF1D76E2), // Blue text
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
