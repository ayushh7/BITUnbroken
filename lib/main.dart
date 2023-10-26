import 'package:firebase_core/firebase_core.dart';
import 'package:bitunbroken/screens/Profile.dart';
import 'package:flutter/material.dart';
import 'package:bitunbroken/screens/login_screen.dart';
import 'package:bitunbroken/screens/signup_screen.dart';
import 'package:bitunbroken/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  runApp(BitUnbrokenApp());
}

class BitUnbrokenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'BitUnbroken',
      theme: ThemeData(
        // primarySwatch: Colors.blue,
        primaryColor: Colors.black,
      ),
      initialRoute: '/login',
      routes: {
        // '/': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}
