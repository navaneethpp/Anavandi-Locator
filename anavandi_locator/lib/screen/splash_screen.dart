// splashScreen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:anavandi_locator/constants/images.dart';
import 'package:anavandi_locator/constants/text.dart';
import 'package:anavandi_locator/screen/home.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Home()));
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content centered
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AppImages.splashScreenImage,
                    width: AppImageWidth.splashScreenImageWidth),
                const SizedBox(height: 20),
                const Text(
                  'Prepare your trip with me...',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: LinearProgressIndicator(
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.blue),
                    backgroundColor: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
          // Version text at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 16.0), // Adjust spacing as needed
              child: Text(
                AppInfo.version,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
