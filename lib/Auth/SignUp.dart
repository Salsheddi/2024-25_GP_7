import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:mirsad/Auth/LogIn.dart';
import 'package:mirsad/Auth/Profile.dart';
import 'package:mirsad/Auth/home.dart';

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

   bool isPasswordVisible = false; // To toggle password visibility
  bool isReenterPasswordVisible = false; // To toggle re-enter password visibility

  // Function to toggle password visibility
  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  // Function to toggle re-enter password visibility
  void toggleReenterPasswordVisibility() {
    setState(() {
      isReenterPasswordVisible = !isReenterPasswordVisible;
    });
  }

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
    setState(() {
      hasUserInteractedWithUsername = true;
      hasUserInteractedWithEmail = true;
      hasUserInteractedWithPassword = true;
      hasUserInteractedWithReenterPassword = true;

      isUsernameValid = usernameController.text.trim().isNotEmpty;
      isEmailValid = isValidEmail(emailController.text.trim());
      isPasswordValid = validatePasswordStructure(passwordController.text.trim());
      isReenteredPasswordMatching = passwordController.text.trim() ==
          reenterPasswordController.text.trim();

      if (!isEmailValid) {
        emailErrorMessage = 'Please enter a valid email';
      }
    });

    if (!isUsernameValid || !isEmailValid || !isPasswordValid || !isReenteredPasswordMatching) {
      return;
    }

    showLoadingDialog();
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Send verification email
      User? user = userCredential.user;
      await user?.sendEmailVerification();

      // Hash the password
      String hashedPassword = hashPassword(passwordController.text.trim());

      await _firestore.collection('users').doc(user!.uid).set({
        'uid': user.uid,
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'password': hashedPassword,
      });

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => VerifyEmail(user: user)),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      setState(() {
        emailErrorMessage = e.code == 'email-already-in-use'
            ? 'This email is already taken'
            : 'An unknown error occurred';
        isEmailValid = false;
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
              // padding above logo
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

              // Username field
             Row(
               children: [
                 Text("Username", style: TextStyle(color: Colors.white)),
                 Text(" *", style: TextStyle(color: Colors.red)),
                 ],
              ),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: 'Enter your username',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 145, 143, 143),
                    fontSize: 15,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 20),
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
              Row(
               children: [
                 Text("E-mail", style: TextStyle(color: Colors.white)),
                 Text(" *", style: TextStyle(color: Colors.red)),
                 ],
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 145, 143, 143),
                    fontSize: 15,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 20),
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
              Row(
               children: [
                 Text("Password", style: TextStyle(color: Colors.white)),
                 Text(" *", style: TextStyle(color: Colors.red)),
                 ],
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: 'At least 8 characters, includes number and symbol',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 145, 143, 143),
                    fontSize: 13,
                    overflow: TextOverflow.ellipsis,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 20),
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: togglePasswordVisibility,
                  ),
                ),
                obscureText: !isPasswordVisible,
                onChanged: (_) {
                  hasUserInteractedWithPassword = true;
                  updateValidation();
                }, // Revalidate while typing
              ),

              SizedBox(height: 15),

              // Re-enter Password field
              Row(
               children: [
                 Text("Re-enter Password", style: TextStyle(color: Colors.white)),
                 Text(" *", style: TextStyle(color: Colors.red)),
                 ],
              ),
              TextFormField(
                controller: reenterPasswordController,
                decoration: InputDecoration(
                  hintText: 'Re-enter your password',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 145, 143, 143),
                    fontSize: 15,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 20),
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
                suffixIcon: IconButton(
                    icon: Icon(
                      isReenterPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: toggleReenterPasswordVisibility,
                  ),
                ),
                obscureText: !isReenterPasswordVisible,
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
                  style: TextStyle(color: Colors.white, fontSize: 18),
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
class VerifyEmail extends StatelessWidget {
  final User user;

  const VerifyEmail({Key? key, required this.user}) : super(key: key);

  Future<void> resendVerificationEmail(User user) async {
    await user.sendEmailVerification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // Correct placement here
        title: Text(
          'Verify Email',
          style: TextStyle(color: Colors.white), // Text color set to white
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Icon color set to white
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0, 
      ),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(70),
                  color: Colors.white.withOpacity(0.75),
                ),
                child: Image.asset('img/Mirsad2.png'),
              ),
            ),
            SizedBox(height: 30),
            Text(
              "Verify Your Email",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "A verification email has been sent to ${user.email}. Please check your inbox.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1C7ECE),
                minimumSize: Size(double.infinity, 53),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              onPressed: () => resendVerificationEmail(user),
              child: Text(
                "Resend Email",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1C7ECE),
                minimumSize: Size(double.infinity, 53),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              onPressed: () async {
                await user.reload(); // Reload user data
                User? updatedUser = FirebaseAuth.instance.currentUser; 
                if (updatedUser != null && updatedUser.emailVerified) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LogIn()),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Email Not Verified"),
                        content: Text(
                            "Your email has not been verified. Please check your inbox and try again."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Close"),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text(
                "I've Verified My Email",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

