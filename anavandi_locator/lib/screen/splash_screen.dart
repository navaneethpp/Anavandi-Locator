// splash_screen.dart

// This page implements the splash screen of the application.
// It is the first screen users see when the app starts, providing a branding moment and
// a visual indication of loading before transitioning to the main application screen.

// Documentation:
//
// Page Purpose:
// The SplashScreen serves as the initial loading screen for the application. It is designed to:
// - Display the application logo and branding to the user upon app launch.
// - Provide a brief loading animation (LinearProgressIndicator) to indicate that the app is starting up.
// - Simulate a startup process (using a `Future.delayed` timer), which can be used to represent actual
//   initialization tasks like loading data, making API calls, or setting up resources in a real application.
// - Automatically navigate to the `MainScreen` after a set delay, transitioning the user to the main app content.
//
// Working:
// - Simulates a loading process using `Future.delayed(const Duration(seconds: 3), () { ... });`.
//   In a real-world application, this `Future.delayed` block would be replaced with actual asynchronous
//   startup tasks (e.g., fetching initial data from a server, initializing local databases, etc.).
// - After the simulated delay (or after real startup tasks are completed), it uses `Navigator.pushReplacement`
//   to navigate to the `MainScreen`. `pushReplacement` is used to replace the SplashScreen in the navigation stack,
//   so the user cannot navigate back to the SplashScreen from the MainScreen.
//
// UI Structure:
// - Scaffold: Sets the basic page structure with a white background color.
// - Center: Centers the content of the splash screen both horizontally and vertically within the Scaffold body.
// - Column: Arranges the content vertically within the Center widget. The Column contains:
//     - Image.asset: Displays the application logo from the 'assets/logo.png' asset.  The width is set to 300.0 for sizing.
//     - SizedBox: Provides vertical spacing (20 pixels) between the logo and the text.
//     - Text: Displays the tagline "Prepare your trip with me..." with a font size of 20.
//     - SizedBox: Provides vertical spacing (20 pixels) between the text and the progress bar.
//     - Padding: Adds horizontal padding (40 pixels on each side) for the `LinearProgressIndicator` to control its width.
//     - LinearProgressIndicator: Displays a linear progress bar to visually indicate loading.
//         - valueColor: Sets the color of the progress bar to blue using `AlwaysStoppedAnimation<Color>(Colors.blue)`.
//         - backgroundColor: Sets the background color of the progress bar track to light grey using `Colors.grey[300]`.

import 'package:anavandi_locator/screen/main_screen.dart';
import 'package:flutter/material.dart';
// import 'dart:ui'; // Not used in this file and can be removed

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
            // CircularProgressIndicator(), // Add a loader while waiting - could be used instead of LinearProgressIndicator
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
