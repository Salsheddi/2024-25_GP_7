import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mirsad/main.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final List<Widget> _navigationItem = [
    const Icon(Icons.smart_toy_outlined, size: 32, color: Colors.white),
    const Icon(Icons.home, size: 32, color: Colors.white),
    const Icon(Icons.person, size: 32, color: Colors.white)
  ];

  Future<void> logOut() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
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
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // Change this to start
                  children: [
                    // user information
                    const SizedBox(height: 40),

                    const Text(
                      "user nameee",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "user email",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),

                    SizedBox(height: 30),

                    //Menu

                    ProfileInfoWidget(
                        text: "Edit Profile",
                        imagePath: 'images/editProfile.png',
                        textColor: Colors.black,
                        backgroundColor: const Color(0xFF707EFF),
                        onPress: () {}),
                    const SizedBox(height: 15),
                    ProfileInfoWidget(
                        text: "About Mirsad",
                        imagePath: 'images/MirsadLogo.png',
                        textColor: Colors.black,
                        backgroundColor: const Color(0xFF2184FC),
                        onPress: () {}),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),
                    ProfileInfoWidget(
                      text: "Log out",
                      imagePath: 'images/Logout.png',
                      textColor: Colors.black,
                      backgroundColor: Color(0xFFFFC046),
                      onPress: logOut,
                      endIcon: false,
                    ),
                    const SizedBox(height: 15),

                    ProfileInfoWidget(
                      text: "Delete Account",
                      imagePath: 'images/delete.png',
                      textColor: Colors.red,
                      backgroundColor: const Color(0xFFE21414),
                      onPress: () {},
                      endIcon: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: const Color(0xFFF7F6F6),
          height: 70,
          color: const Color(0xFF2184FC).withOpacity(0.65),
          animationDuration: const Duration(milliseconds: 350),
          onTap: (index) {},
          items: _navigationItem),
    );
  }
}

class ProfileInfoWidget extends StatelessWidget {
  final String text;
  final String imagePath;
  final Color textColor;
  final Color backgroundColor;
  final VoidCallback onPress;
  final bool endIcon;

  const ProfileInfoWidget({
    super.key,
    required this.text,
    required this.imagePath,
    required this.textColor,
    required this.backgroundColor,
    required this.onPress,
    this.endIcon = true,
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
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      title: Text(text,
          style: TextStyle(
              color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
      trailing: endIcon
          ? Container(
              width: 34,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(80),
                color: Colors.grey.withOpacity(0.1),
              ),
              child: Image.asset(
                'images/ArrowRight.png',
                fit: BoxFit.contain,
              ),
            )
          : null,
    );
  }
}
