import 'package:bitunbroken/screens/users_screen.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/events.dart';
import '../components/jobs.dart';
import 'Profile.dart';
import 'login_screen.dart';

class HomePage extends StatefulWidget {
  final User? user;

  HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final primaryColor=Color(0xFF1C1A1A);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<_HomePageState> homeScreenKey = GlobalKey<_HomePageState>();


  String imageUrl = '';

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

  bool _isLoading = false;
  List<DocumentSnapshot> _posts = []; // Store the loaded posts
  int _postBatchSize = 10;

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }


    // Implement your logic to fetch more posts here
    // You can use a pagination query to retrieve additional posts
    // For example, you can keep track of the last visible post and fetch the next batch of posts.

    // After fetching, add the new posts to your existing list or data structure.



// Dispose the scroll controller when the widget is disposed



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
        key: homeScreenKey,
        onWillPop: _onBackPressed,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Unbroken'),
            backgroundColor: primaryColor,
            actions: [
              IconButton(
                icon: Icon(Icons.event),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EventsPage()),
                  );
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => JobsPage()),
                  );
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

            body: Stack(
              children: [
                // Background Image
                Image.asset(
                  'assets/images/background7.jpg', // Replace with the path to your image asset
                  fit: BoxFit.cover, // You can adjust the fit as needed
                  width: double.infinity,
                  height: double.infinity,
                ),
                // Your existing content
                _buildPage(_selectedIndex, imageUrl),
              ],
            ),
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

  Widget _buildPage(int index, String imageUrl) {
    if (index == 0) {
      return RefreshIndicator(
        onRefresh: _refreshData, // Define the refresh action
        child: Column(
          children: [
            Expanded(
             child:StreamBuilder<QuerySnapshot>(
               stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
               builder: (context, snapshot) {
                 if (!snapshot.hasData) {
                   return Center(child: CircularProgressIndicator());
                 }
                 final posts = snapshot.data!.docs;
                 List<Widget> postWidgets = [];
                 for (var postDocument in posts) {
                   final data = postDocument.data() as Map<String, dynamic>;
                   final username = data['uid']; // The user's uid associated with the post
                   final text = data['text'] ?? "";

                   postWidgets.add(
                     FutureBuilder<DocumentSnapshot>(
                       future: FirebaseFirestore.instance.collection('users').doc(username).get(),
                       builder: (context, userSnapshot) {
                         if (userSnapshot.connectionState == ConnectionState.waiting) {
                           // return CircularProgressIndicator(); // Show a loading indicator
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

                         final post = Post(name, postContent, imageUrl); // Use the user's name

                         return PostWidget(post: post, imageUrl: imageUrl, currentUser: widget.user, postDocument: postDocument);
                       },
                     ),
                   );
                 }

                 return ListView(
                   children: postWidgets,
                 );
               },
             )

            ),
          ],
        ),
      );
    } else if (index == 1) {
      return AddPostWidget(user: widget.user);
    } else if (index == 2) {
      return ProfilePage(
        user: widget.user,
        onImageUrlChanged: (newImageUrl) {
          setState(() {
            imageUrl = newImageUrl;
          });
        },
      );
    }

    return Container();
  }

  Future<void> _refreshData() async {
    // Fetch the latest data here, for example, refetch posts from Firestore
    // Replace this with your actual data fetching logic
    await Future.delayed(Duration(seconds: 1));

    // After fetching new data, rebuild the entire page
    setState(() {});
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
      // _onItemTapped(0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post created successfully'),
          duration: Duration(seconds: 2), // Adjust the duration as needed
        ),
      );

// Close the bottom sheet
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              // hintText: "Logged in as ${widget.user?.email}",
              hintText: "Create Post...",
              hintStyle: TextStyle(
                color: Colors.white, // Replace 'Colors.red' with the color you want
              ),

            ),
            onChanged: (text) {
              setState(() {
                postText = text;
              });
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _createPost();
              // Navigator.of(context).pop(); // Close the dialog
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white), // Replace with your desired button color
            ),
            child: Text("Post", style: TextStyle(color: Colors.black))
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
  final DocumentSnapshot postDocument;
  final String imageUrl;
  final User? currentUser; // Pass the current user to the widget


  PostWidget({required this.post, required this.imageUrl, required this.currentUser,required this.postDocument});

  void _deletePost(BuildContext context, String postDocId) async {
    if (postDocId != null && post.username == currentUser?.uid) {
      // Check if the current user is the creator of the post and the postDocId is not null
      await FirebaseFirestore.instance.collection('posts').doc(postDocId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are not authorized to delete this post'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              // backgroundImage:CachedNetworkImageProvider(imageUrl)
                  backgroundImage: AssetImage('assets/images/background4.jpg'),
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
          if (post.username == currentUser?.uid) // Display the delete icon for the post creator
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deletePost(context, postDocument.id); // Pass the document ID
              },
            ),

        ],
      ),
    );
  }
}
