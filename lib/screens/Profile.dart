import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final User? user; // Pass the authenticated user to this screen

  ProfilePage({this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = 'Ayush Singh';
  String phoneNumber = '6200769010';
  String location = 'Bokaro Steel City';
  String profileImagePath = 'assets/images/profile/profile.jpg'; // Provide a default image path

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFFBB619D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  // Handle profile image editing
                  // You can open an image picker or a dialog for image selection here.
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(profileImagePath),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Name: ${widget.user?.displayName}', // Display user's name
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8),
            Text(
              'Phone Number: $phoneNumber',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            GestureDetector(
              onTap: () {
                // Handle phone number editing
                // You can open a dialog or navigate to an edit screen.
              },
              child: Text(
                'Edit Phone Number',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.pink,
                  decoration: TextDecoration.underline,

                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Location: $location',
              style: TextStyle(fontSize: 18),textAlign: TextAlign.center,
            ),

            GestureDetector(
              onTap: () {
                // Handle location editing
                // You can open a dialog or navigate to an edit screen.
              },
              child: Text(
                'Edit Location',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.pink,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
