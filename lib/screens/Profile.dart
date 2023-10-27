import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfilePage extends StatefulWidget {
  final User? user;

  ProfilePage({this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String currentDesignation = '';
  String email = '';
  String name = '';
  String passingBatch = '';
  String phoneNumber = '';

  final DatabaseReference _userRef =
  FirebaseDatabase.instance.reference().child('users'); // Reference to the Realtime Database

  // Function to fetch user data from Realtime Database
  Future<void> fetchUserData() async {
    try {
      final userUid = widget.user?.uid;
      if (userUid != null) {
        print("User UID: $userUid");
        final userSnapshot = await _userRef.child(userUid).once();
        final userData = userSnapshot.snapshot.value as Map<String, dynamic>;

        if (userData != null) {
          setState(() {
            currentDesignation = userData['currentDesignation'] ?? '';
            email = userData['email'] ?? '';
            name = userData['name'] ?? '';
            passingBatch = userData['passingBatch'] ?? '';
            phoneNumber = userData['phoneNumber'] ?? '';
          });
        }
      }
    } catch (e) {
      // Handle any errors here
      print('Error fetching user data: $e');
      }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

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
                  // You can set the profile image here
                  // backgroundImage: AssetImage('path_to_profile_image'),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Name: $name', // Display user's name
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Email: $email',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Current Designation: $currentDesignation',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Passing Batch: $passingBatch',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Phone Number: $phoneNumber',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
