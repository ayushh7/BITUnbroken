import 'package:flutter/material.dart';
import 'package:bitunbroken/screens/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart'; // Import your login_screen.dart or provide the correct import path.

class HomePage extends StatefulWidget {
  final User? user; // Make the user parameter nullable

  HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final primaryColor = Color(0xFFBB619D);

  String userName = "User"; // Default name if not found

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  void fetchUserName() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        print("Fetching user data for UID: ${user.uid}");
        if (documentSnapshot.exists) {
          print("User data found: ${documentSnapshot.data()}");
          setState(() {
            userName = documentSnapshot['name'];
          });
        } else {
          print("User data not found for UID: ${user.uid}");
        }
      });
    } else {
      print("User is not authenticated.");
    }
  }


  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unbroken'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.event),
            onPressed: () {
              // Handle Events button action
            },
          ),
          IconButton(
            icon: Icon(Icons.people),
            onPressed: () {
              // Handle People button action
            },
          ),
          IconButton(
            icon: Icon(Icons.work),
            onPressed: () {
              // Handle Jobs button action
            },
          ),
          IconButton(
            icon: Icon(Icons.logout), // Add a sign-out button
            onPressed: () {
              _signOut(context);
            },
          ),
        ],
      ),
      body: Container(
        // color: backgroundColor,
        child: Center(
            child: Text('Welcome, $userName'),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: primaryColor,
        backgroundColor: Colors.white,
        onTap: (int index) {
          if (index == 2) {
            // If the "Profile" tab is tapped (index 2), navigate to the profile page.
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ProfilePage(user: FirebaseAuth.instance.currentUser),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return AddPostWidget(user: widget.user);
            },
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: primaryColor,
      ),
    );
  }
}
class AddPostWidget extends StatefulWidget {
  final User? user; // Change the parameter type to User?

  AddPostWidget({required this.user});

  @override
  _AddPostWidgetState createState() => _AddPostWidgetState();
}

class _AddPostWidgetState extends State<AddPostWidget> {
  String postText = "";

  void _createPost() async {
    if (postText.isNotEmpty) {
      await FirebaseFirestore.instance.collection('posts').add({
        'uid': widget.user?.uid,
        'text': postText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        postText = "";
      });

      // Close the bottom sheet
      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Logged in as ${widget.user?.email}",
            ),
            onChanged: (text) {
              setState(() {
                postText = text;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              _createPost();
            },
            child: Text("Post"),
          ),
        ],
      ),
    );
  }
}



class Post {
  final String username;
  final String content;
  final String imagePath;

  Post(this.username, this.content, this.imagePath);
}

class PostWidget extends StatelessWidget {
  final Post post;

  PostWidget({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      elevation: 2,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(post.imagePath),
            ),
            title: Text(
              post.username,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(post.content),
          ),
          Image.asset(
            post.imagePath,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        // Handle like button tap
                        // You can change the state or perform other actions here.
                        Icon(Icons.favorite);
                      },
                      child: Icon(Icons.favorite_border),
                    ),
                    // Other widgets...
                  ],
                ),
                SizedBox(width: 20), // Add spacing between icons
                Icon(Icons.chat_bubble_outline),
                SizedBox(width: 20), // Add spacing between icons
                Icon(Icons.share),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
