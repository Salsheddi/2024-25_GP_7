import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:mirsad/Auth/LogIn.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
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
                hintText: 'E-mail',
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
                hintText: 'Phone Number',
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

        // sign up button
        MaterialButton(
          height: 53,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          color: Colors.white,
          onPressed: () {},
          child: Text(
            "Sign up",
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
              "You have an acount? ",
              style: TextStyle(color: Colors.white),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const Login()), // Navigate to LogIn page
                );
              },
              child: const Text(
                "Log in now!",
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
