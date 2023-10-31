import 'package:bitunbroken/screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'home_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showAlert(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // _showAlert('Success', 'You have successfully signed in.');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged in successfully'),
            duration: Duration(seconds: 2), // Adjust the duration as needed
          ),

        );Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => HomePage(user: FirebaseAuth.instance.currentUser)));

      }
    } catch (e) {
      print("Error signing in: $e");
      _showAlert('Error', 'Incorrect email or password. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background4.jpg'), // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Welcome to BITUnbroken!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      _signIn();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF6F2F2),
                      shape: StadiumBorder(),
                    ),
                    child: Text(
                      'Sign in',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Container(
                //   width: double.infinity,
                //   padding: EdgeInsets.symmetric(horizontal: 20),
                //   child: ElevatedButton.icon(
                //     onPressed: () {
                //       // Add Google Sign-In logic here
                //     },
                //
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.white,
                //       shape: StadiumBorder(),
                //     ),
                //     icon: Icon(
                //       FontAwesomeIcons.google,
                //       color: Colors.black,
                //       size: 17,
                //     ),
                //     label: Text(
                //       'Sign in with Google',
                //       style: TextStyle(color: Colors.black),
                //     ),
                //   ),
                // ),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SignUpPage(),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFEAE9E9),
                      shape: StadiumBorder(),
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
