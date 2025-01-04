// main.dart

import 'package:flutter/material.dart';
import 'dart:ui';

import 'bus_selection_menu.dart';
import 'favorite_page.dart';
import 'recent_page.dart';
import 'about_page.dart';
import 'NotificationPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anavandi Locator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(), // Start with SplashScreen
    );
  }
}

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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2;

  final List<Widget> _pages = [
    const FavoritePage(),
    RecentPage(),
    const BusSelectionMenu(),
    NotificationPage(),
    const AboutPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image with blur and dark overlay
        Positioned.fill(
          child: Stack(
            children: [
              Image.asset(
                'assets/bg.png', // Replace with your image path
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: Container(
                  color: Colors.black
                      .withOpacity(0.5), // Adjust opacity for desired shading
                ),
              ),
            ],
          ),
        ),
        Scaffold(
          backgroundColor:
              Colors.transparent, // Make Scaffold background transparent
          body: _pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.cyanAccent,
            unselectedItemColor: Colors.white,
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            backgroundColor: Colors
                .transparent, // Set BottomNavigationBar background to transparent
            elevation: 0,
            iconSize: 25, // Default size for unselected icons
            items: [
              BottomNavigationBarItem(
                icon: AnimatedSwitcher(
                  duration: const Duration(
                      milliseconds: 300), // Duration of the animation
                  child: Icon(
                    Icons.favorite,
                    key: ValueKey<int>(_currentIndex),
                    size: _currentIndex == 0
                        ? 30
                        : 25, // Set size to 50 if selected, otherwise 30
                  ),
                ),
                label: 'Favorite',
              ),
              BottomNavigationBarItem(
                icon: AnimatedSwitcher(
                  duration: const Duration(
                      milliseconds: 300), // Duration of the animation
                  child: Icon(
                    Icons.history,
                    key: ValueKey<int>(_currentIndex),
                    size: _currentIndex == 1
                        ? 30
                        : 20, // Set size to 50 if selected, otherwise 30
                  ),
                ),
                label: 'Recent',
              ),
              BottomNavigationBarItem(
                icon: AnimatedSwitcher(
                  duration: const Duration(
                      milliseconds: 300), // Duration of the animation
                  child: Icon(
                    Icons.directions_bus,
                    key: ValueKey<int>(_currentIndex),
                    size: _currentIndex == 2
                        ? 30
                        : 20, // Set size to 50 if selected, otherwise 30
                  ),
                ),
                label: 'Bus Selection',
              ),
              BottomNavigationBarItem(
                icon: AnimatedSwitcher(
                  duration: const Duration(
                      milliseconds: 300), // Duration of the animation
                  child: Icon(
                    Icons.notifications,
                    key: ValueKey<int>(_currentIndex),
                    size: _currentIndex == 3
                        ? 30
                        : 20, // Set size to 50 if selected, otherwise 30
                  ),
                ),
                label: 'Notification',
              ),
              BottomNavigationBarItem(
                icon: AnimatedSwitcher(
                  duration: const Duration(
                      milliseconds: 300), // Duration of the animation
                  child: Icon(
                    Icons.info,
                    key: ValueKey<int>(_currentIndex),
                    size: _currentIndex == 4
                        ? 30
                        : 20, // Set size to 50 if selected, otherwise 30
                  ),
                ),
                label: 'About',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
