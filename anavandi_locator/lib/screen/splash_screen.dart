// splash_screen.dart

import 'package:anavandi_locator/screen/main_screen.dart';
import 'package:flutter/material.dart';
// import 'dart:ui';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulate a loading process (like API call, data loading, etc.)
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png', // Ensure this asset is available
              width: 300.0,
            ),
            // CircularProgressIndicator(), // Add a loader while waiting
            const SizedBox(height: 20),
            const Text(
              'Prepare your trip with me...',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            // Add the linear progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: LinearProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                backgroundColor: Colors.grey[300],
              ),
            ), // Message for user
          ],
        ),
      ),
    );
  }
}
