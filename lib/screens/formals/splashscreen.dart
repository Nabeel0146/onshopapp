import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onshopapp/mainscree.dart';
import 'package:onshopapp/screens/homepage.dart';
import 'package:onshopapp/screens/register.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    // Define scale animation
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Start animation
    _controller.forward();

    // Initialize Firebase and check login status
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Ensure Firebase is initialized
      await Firebase.initializeApp();

      // Check user login status after a delay
      Timer(Duration(seconds: 2), _checkUserLoginStatus);
    } catch (e) {
      // Handle Firebase initialization error
      print('Firebase initialization error: $e');
      _showErrorDialog();
    }
  }

  void _checkUserLoginStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Navigate to HomePage if logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      // Navigate to RegisterPage if not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RegisterPage()),
      );
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Failed to initialize Firebase. Please try again later.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'asset/ssbackground.jpg',
            fit: BoxFit.cover,
          ),
          // Centered logo with zoom animation
          Center(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: Image.asset(
                'asset/appbarlogo.png', // Logo image
                width: 200,
                height: 200,
              ),
            ),
          ),
        ],
      ),
    );
  }
}