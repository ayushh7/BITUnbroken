import 'package:bitunbroken/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Profile.dart';
import 'login_screen.dart';

class HomePage extends StatefulWidget {
  final User? user;

  HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final primaryColor = Color(0xFFBB619D);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Handle back button press
  Future<bool> _onBackPressed() {
    if (_selectedIndex != 0) {
      // If not in the first tab, navigate to the first tab
      setState(() {
        _selectedIndex = 0;
      });
      return Future.value(false); // Do not close the app
    }
    return Future.value(true); // Close the app if already in the first tab
  }
  int _selectedIndex = 0;

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressed,
    child: Scaffold(
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
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserListScreen()),
              );
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
      body: _buildPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: primaryColor,
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    ));
  }

  Widget _buildPage(int index) {
    if (index == 0) {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final postDocument = snapshot.data!.docs[index];
              final data = postDocument.data() as Map<String, dynamic>;
              final username = data['uid']; // The user's uid associated with the post
              final text = data['text'] ?? "";

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(username).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (userSnapshot.hasError) {
                    return Text('Error: ${userSnapshot.error}');
                  }

                  if (!userSnapshot.hasData) {
                    return Text('No user data found'); // Handle this case as needed
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final name = userData['name'] ?? "";
                  final email = userData['email'] ?? "";

                  final postContent = text;

                  final post = Post(name, postContent, ""); // Use the user's name

                  return PostWidget(post: post);
                },
              );
            },
          );
        },
      );
    }
    else if (index == 1) {
      return AddPostWidget(user: widget.user);
    } else if (index == 2) {
      return ProfilePage(user: widget.user);
    }

    return Container();
  }
}

class AddPostWidget extends StatefulWidget {
  final User? user;

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

      // Navigator.pop(context); // Close the bottom sheet
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
              // Add user profile image here
              // backgroundImage: NetworkImage('profile_image_url'),
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
        ],
      ),
    );
  }
}
