// home_page.dart
import 'package:flutter/material.dart';
import 'package:anavandi_locator/presentation/screens/about_page.dart';
import 'package:anavandi_locator/presentation/screens/home_content.dart';
import 'package:anavandi_locator/presentation/screens/home/home_submit_handler.dart';
import 'package:anavandi_locator/data/models/bus_route.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:anavandi_locator/presentation/widgets/custom_bottom_nav_bar.dart'; // Import the new widget

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anavandi Locator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final TextEditingController _textField1Controller = TextEditingController();
  final TextEditingController _textField2Controller = TextEditingController();
  final GlobalKey<HomeContentState> _homeContentKey =
      GlobalKey<HomeContentState>();

  static const MethodChannel _channel = MethodChannel(
    'com.example.anavandi_locator/location_settings',
  );

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    PermissionStatus status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
      if (status.isGranted) {
        print('Location permission granted.');
        _checkLocationService();
      } else if (status.isPermanentlyDenied) {
        _showPermissionDeniedDialog();
      } else {
        print('Location permission denied.');
      }
    } else if (status.isGranted) {
      print('Location permission already granted.');
      _checkLocationService();
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
    } else if (status.isLimited) {
      print('Location permission is limited (iOS).');
      _checkLocationService();
    }
  }

  Future<void> _checkLocationService() async {
    bool serviceEnabled = await Permission.location.serviceStatus.isEnabled;
    if (!serviceEnabled) {
      _showLocationServiceDisabledDialog();
    } else {
      print('Location service is enabled.');
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'This app needs location permission to find bus routes near you. Please grant the permission in the app settings.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Service Disabled'),
          content: const Text(
            'Your device\'s location service is turned off. Please turn it on to use the location-based features of this app.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Location Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                _openLocationSettings();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _openLocationSettings() async {
    try {
      await _channel.invokeMethod('openLocationSettings');
    } on PlatformException catch (e) {
      print("Error opening location settings: '${e.message}'");
      // Show a user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open location settings: ${e.message}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleRouteFound(List<BusRoute> route) {
    _homeContentKey.currentState?.updateRoute(route);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child:
                _selectedIndex == 0
                    ? const Text('Anavandi Locator', key: ValueKey<int>(0))
                    : const SizedBox.shrink(key: ValueKey<int>(1)),
          ),
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: <Widget>[
            HomeContent(
              key: _homeContentKey,
              startPointController: _textField1Controller,
              destinationController: _textField2Controller,
              onRouteFound: _handleRouteFound,
              onSubmit: () {
                HomeSubmitHandler.handleSubmit(
                  context,
                  _textField1Controller,
                  _textField2Controller,
                  _handleRouteFound,
                );
              },
            ),
            const AboutPage(),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onButtonPressed: _onItemTapped,
          activeColor: Theme.of(context).primaryColor,
          barItems: <BarItem>[
            BarItem(icon: Icons.home, title: 'Home'),
            BarItem(icon: Icons.info, title: 'About'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textField1Controller.dispose();
    _textField2Controller.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
