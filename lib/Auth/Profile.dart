// ignore_for_file: unused_import

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mirsad/Auth/LogIn.dart';
import 'package:mirsad/Auth/ResetPass.dart';
import 'package:mirsad/Auth/SignUp.dart';
import 'package:mirsad/Auth/chatbot.dart';
import 'package:mirsad/Auth/home.dart';
import 'package:mirsad/Auth/utlis.dart';
import 'package:mirsad/main.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _currentIndex = 2; // Initially, the profile tab is selected
  bool _isNavBarVisible = true; // Control visibility of bottom navigation bar

  
  String? userName;
  String? userEmail;
  Uint8List? image;
  final _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  //select image
  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      image = img;
    });
  }
  

  // Fetch the user details from Firestore
  Future<void> _fetchUserDetails() async {
    try {
      User? user = FirebaseAuth.instance.currentUser; // Get the current user
      if (user != null) {
        userEmail = user.email;

        // Fetch user data from Firestore based on the user's email
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc['username'];
            _usernameController.text = userName ?? '';
          });
        } else {
          print('User document does not exist in Firestore.');
        }
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

// update username function
  Future<void> _updateUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'username': _usernameController.text});

        setState(() {
          userName = _usernameController.text;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update username: $e')),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    // Show a confirmation dialog
    bool? confirmReset = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: const Text(
              'Are you sure you want to reset your password? You will be logged out if you proceed.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled the reset
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed the reset
              },
              child: const Text('Yes, Reset'),
            ),
          ],
        );
      },
    );

    if (confirmReset == true) {
      try {
        if (userEmail != null && userEmail!.isNotEmpty) {
          // Send the reset password email
          await FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail!);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password reset email sent to $userEmail')),
          );

          // Log out the user after sending the password reset email
          await FirebaseAuth.instance.signOut();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out successfully.')),
          );
        } else {
          // Handle the case where userEmail is null or empty
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please enter a valid email address.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send reset email: $e')),
        );
      }
    }
  }

  Future<void> logOut() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to log out: $e')));
    }
  }

  void LogOutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                logOut(); // Call log out function
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  Future<void> DeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                deleteAccount(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteAccount(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Show a dialog to get the user's password
      String? password = await _showPasswordDialog(context);
      if (password == null) return; // User canceled the password dialog

      try {
        // Reauthenticate the user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);

        // Proceed to delete the account
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();
        await user.delete();

        // Navigate to the main page after account deletion
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const MainPage()), // Replace MainPage with your main page widget
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account successfully deleted.')),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Failed to delete account')),
        );
      } catch (e) {
        // Handle Firestore or other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: $e')),
        );
      }
    }
  }

  Future<String?> _showPasswordDialog(BuildContext context) async {
    String? password;
    final TextEditingController passwordController = TextEditingController();

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Enter your password'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                password = passwordController.text;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0xFF2184FC),
                Color(0xFFA4E2EC),
              ]),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 60.0, left: 22),
              child: Text(
                "My Profile",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 160.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40)),
                color: Color(0xFFF7F6F6),
              ),
              height: double.infinity,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // user information

                      const SizedBox(height: 20),
                      Stack(children: [
                        image != null
                            ? CircleAvatar(
                                radius: 40,
                                backgroundImage: MemoryImage(image!),
                              )
                            : const CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage("img/user.png"),
                              ),
                        Positioned(
                          child: IconButton(
                              onPressed: selectImage,
                              icon: const Icon(Icons.add_a_photo_outlined)),
                          right: -12,
                          bottom: -15,
                        ),
                      ]),
                      Text(
                        userName ??
                            "Loading...", // Use "Loading..." if userName is null

                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),

                      Text(
                        userEmail ??
                            "Loading...", // Use "Loading..." if userEmail is null

                        style:
                            const TextStyle(color: Colors.black, fontSize: 18),
                      ),

                      SizedBox(height: 20),

                      //Menu
                      Container(
                        width: double.infinity, // Set the desired width
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12), // Adjust padding
                        child: TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Edit Username',
                            labelStyle: const TextStyle(
                              color: Color(
                                  0xFF1D76E2), // Customize the label color
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),

                            // Set the border when the TextFormField is not focused
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color:
                                    Color(0xFF1D76E2), // Unfocused border color
                                width: 1.5, // Border thickness
                              ),
                            ),

                            // Set the border when the TextFormField is focused
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color:
                                    Color(0xFF1D76E2), // Focused border color
                                width: 2.0, // Focused border thickness
                              ),
                            ),

                            prefixIcon: const Icon(
                              Icons.person, // Add an icon to the left
                              color: Color(0xFF1D76E2), // Icon color
                            ),

                            // save button
                            suffix: ElevatedButton(
                              onPressed:
                                  _updateUsername, // Perform the update action
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF1D76E2).withOpacity(
                                    0.9), // Set the background color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // Button border radius
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                    color: Colors.white), // Button text color
                              ),
                            ),

                            filled: true,
                            fillColor: Colors.white, // Background color
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black, // Text size and color
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ProfileInfoWidget(
                          text: "Reset Password",
                          iconData: Icons.lock_reset_rounded,
                          textColor: Colors.black,
                          backgroundColor: Color(0xFF2184FC),
                          onPress: _resetPassword),

                      const SizedBox(height: 5),

                      const Divider(),

                      const SizedBox(height: 5),

                      ProfileInfoWidget(
                        text: "Log out",
                        iconData: Icons.logout,
                        textColor: Colors.black,
                        backgroundColor: Color(0xFF2184FC),
                        onPress: LogOutConfirmationDialog,
                      ),

                      const SizedBox(height: 5),

                      const Divider(),

                      const SizedBox(height: 5),
                      ProfileInfoWidget(
                        text: "Delete Account",
                        iconData: Icons.delete_outlined,
                        textColor: Colors.black,
                        backgroundColor: Color(0xFF2184FC),
                        onPress: () {
                          DeleteConfirmationDialog(
                              context); // Call the correct function with context
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileInfoWidget extends StatelessWidget {
  final String text;

  final IconData iconData;

  final Color textColor;

  final Color backgroundColor;

  final VoidCallback onPress;

  const ProfileInfoWidget({
    super.key,
    required this.text,
    required this.iconData,
    required this.textColor,
    required this.backgroundColor,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        height: 100,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: backgroundColor.withOpacity(0.2)),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              iconData, // Use your desired icon here, e.g., Icons.favorite
              color: Colors.black, // Define the color of the icon
              size: 35, // Set the size of the icon
            ),
          ),
        ),
      ),
      title: Text(text,
          style: TextStyle(
              color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
