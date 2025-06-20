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
   \
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

        // Delete related messages and summaries
        await deleteRelatedMessagesAndSummaries(user.uid);

        // Delete user data from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();

        // Delete user from Firebase Authentication
        await user.delete();

        // Navigate to the main page after account deletion
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const MainPage()), // Replace with your main page widget
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account successfully deleted.')),
        );
      } catch (e) {}
    }
  }

  Future<void> deleteRelatedMessagesAndSummaries(String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference reportedMessages = firestore.collection('messages');
    CollectionReference reportedMessagesSummary =
        firestore.collection('reportedMessagesSummary');

    try {
      // Fetch all reported messages by the user
      QuerySnapshot snapshot =
          await reportedMessages.where('userId', isEqualTo: userId).get();

      if (snapshot.docs.isEmpty) {
        print("No reported messages found for user: $userId");
        return;
      }

      // Start a batch to delete messages efficiently
      WriteBatch batch = firestore.batch();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        String messageContent =
            doc['message']; // Use 'message' instead of hashContent
        print("Preparing to delete message: $messageContent");

        // Delete the reported message
        batch.delete(doc.reference);

        // Find the corresponding summary document using messageContent
        QuerySnapshot summarySnapshot = await reportedMessagesSummary
            .where('messageContent', isEqualTo: messageContent)
            .limit(1)
            .get();

        if (summarySnapshot.docs.isNotEmpty) {
          DocumentSnapshot summaryDoc = summarySnapshot.docs.first;
          DocumentReference summaryRef =
              reportedMessagesSummary.doc(summaryDoc.id);

          Map<String, dynamic> data = summaryDoc.data() as Map<String, dynamic>;
          List<dynamic> reportedUsers = List.from(data['reportedUsers'] ?? []);

          // Remove user from the list
          reportedUsers.remove(userId);

          if (reportedUsers.isEmpty) {
            print("Deleting summary for messageContent: $messageContent");
            batch.delete(summaryRef);
          } else {
            print(
                "Updating summary for messageContent: $messageContent. New count: ${reportedUsers.length}");
            batch.update(summaryRef, {
              'counter': reportedUsers.length,
              'reportedUsers': reportedUsers,
            });
          }
        } else {
          print(
              "No summary document found for messageContent: $messageContent");
        }
      }

      // Commit batch operations
      await batch.commit();
      print("All related messages and summaries deleted/updated successfully.");
    } catch (e) {
      print("Error deleting messages and summaries: $e");
    }
  }

  Future<String?> _showPasswordDialog(BuildContext context) async {
    String? password;
    final TextEditingController passwordController = TextEditingController();

    bool isPasswordVisible = false; // Control the visibility of the password
    bool isPasswordInvalid = false; // Flag to track if the password is invalid

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Confirm Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible, // Toggle visibility
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible =
                                !isPasswordVisible; // Toggle visibility
                          });
                        },
                      ),
                    ),
                  ),
                  if (isPasswordInvalid)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Incorrect password. Please try again.',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                ],
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
                  onPressed: () async {
                    password = passwordController.text;

                    // Check if the password is correct before closing
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      try {
                        // Try to reauthenticate
                        AuthCredential credential =
                            EmailAuthProvider.credential(
                          email: user.email!,
                          password: password!,
                        );
                        await user.reauthenticateWithCredential(credential);

                        Navigator.of(context)
                            .pop(password); // Success, return password
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          isPasswordInvalid =
                              true; // Show error message if password is incorrect
                        });
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );

    return password; // Return the password after the dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            color: Color(0xFF2184FC).withOpacity(0.76),
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
            padding: const EdgeInsets.only(top: 130.0),
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

                      const SizedBox(height: 50),
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Stack(children: [
                                image != null
                                    ? CircleAvatar(
                                        radius: 40,
                                        backgroundImage: MemoryImage(image!),
                                      )
                                    : const CircleAvatar(
                                        radius: 40,
                                        backgroundImage:
                                            AssetImage("img/user.png"),
                                      ),
                                Positioned(
                                  child: IconButton(
                                      onPressed: selectImage,
                                      icon: const Icon(
                                          Icons.add_a_photo_outlined)),
                                  right: -12,
                                  bottom: -15,
                                ),
                              ]),
                              const SizedBox(height: 10),
                              Text(
                                userName ?? "Loading...",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                userEmail ?? "Loading...",
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 18),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
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
                                      color: Color(
                                          0xFF1D76E2), // Unfocused border color
                                      width: 1.5, // Border thickness
                                    ),
                                  ),

                                  // Set the border when the TextFormField is focused
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(
                                          0xFF1D76E2), // Focused border color
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
                                      backgroundColor: Color(0xFF1D76E2)
                                          .withOpacity(
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
                                          color: Colors
                                              .white), // Button text color
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
                              const SizedBox(height: 20),
                              ListTile(
                                onTap: _resetPassword,
                                leading: const Icon(
                                  Icons.lock_reset_rounded,
                                  color: Color(0xFF2184FC),
                                  size: 35,
                                ),
                                title: const Text("Reset Password",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 5),
                              ListTile(
                                onTap: LogOutConfirmationDialog,
                                leading: const Icon(
                                  Icons.logout,
                                  color: Color(0xFF2184FC),
                                  size: 30,
                                ),
                                title: const Text("Log out",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 5),
                              ListTile(
                                onTap: () => DeleteConfirmationDialog(context),
                                leading: const Icon(
                                  Icons.delete_outlined,
                                  color: Color(0xFF2184FC),
                                  size: 35,
                                ),
                                title: const Text("Delete Account",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
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
