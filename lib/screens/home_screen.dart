import 'package:flutter/material.dart';
import 'package:bitunbroken/screens/profile.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final primaryColor = Color(0xFFBB619D);
  final backgroundColor = Color(0xFF0C0C0C);

  List<Post> posts = List.generate(
      10, (index) => Post('User $index', 'This is post $index', 'assets/images/default.jpg'));

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

        ],
      ),
      body: Container(
        color: backgroundColor,
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostWidget(post: posts[index]);
          },
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
              builder: (context) => ProfilePage(),
            ));
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add a post logic here
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
      color: Colors.white, // White background color
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
