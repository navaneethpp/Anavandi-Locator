// main_screen.dart
// This page is the entry page of the app and sets up the main user interface structure.
// It defines the MainScreen widget which serves as the base for the entire application,
// incorporating a background image, a bottom navigation bar, and page switching functionality.

// Working:
// - Sets up the main application screen using a Stack to layer background elements and the main Scaffold.
// - Implements a full-screen background image with a blur effect and a dark overlay for visual styling.
// - Uses a Scaffold as the primary layout container, making its background transparent to show the Stack background.
// - Defines a BottomNavigationBar for tab-based navigation, allowing users to switch between different sections of the app.
// - Manages page switching using `_currentIndex` to track the currently selected tab and a `_pages` List to hold the widgets for each tab (FavoritePage, RecentPage, BusSelectionMenu, NotificationPage, AboutPage).
// - Uses `AnimatedSwitcher` to provide animated transitions for the icons in the BottomNavigationBar when tabs are switched, enhancing the user experience with visual feedback on selection.
// - The `_onTabTapped` function updates the `_currentIndex` state variable, triggering a rebuild of the Scaffold body to display the corresponding page from the `_pages` list.

import 'package:anavandi_locator/widgets/bus_selection_menu.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'favorite_page.dart';
import 'recent_page.dart';
import 'about_page.dart';
import 'notification_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2;

  final List<Widget> _pages = [
    const FavoritePage(),
    const RecentPage(),
    const BusSelectionMenu(),
    const NotificationPage(),
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
                  color: Colors.black.withValues(
                      alpha: 0.6), // Adjust opacity for desired shading
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
