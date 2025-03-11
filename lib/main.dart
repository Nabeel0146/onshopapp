import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onshopapp/screens/formals/splashscreen.dart';

void main() async {
  // Ensure Firebase is initialized before the app starts
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with explicit options
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyA25VFkfI6Xno5xzf3BQ3FtwXqOKEzSqp4', // Replace with your actual API key
        appId: '1:676046608509:ios:b020f14aaa88d4cb84f914', // Replace with your actual App ID
        messagingSenderId: '676046608509', // Replace with your Messaging Sender ID
        projectId: 'com.onshopin.onshopapp', // Replace with your Project ID
         // Replace with your Storage Bucket
      ),
    );
    print("Firebase initialized successfully!");
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OnShop App',
     
      home: SplashScreen(), // Show SplashScreen first
    );
  }
}