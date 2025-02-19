import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart'; // Import for AndroidSettings
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:math' as math;
import 'dart:async';
import 'package:intl/intl.dart'; // Import for formatting speed

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anavandi Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Anavandi Companion'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String bdata = "START";
  double latitude = 0.0;
  double longitude = 0.0;
  double _previousLatitude = 0.0;
  double _previousLongitude = 0.0;
  bool locationInitialized = false;
  Timer? _locationUpdateTimer;
  bool _isUpdatingLocation = false;
  double _lastUpdateTime = 0;
  double _speed = 0.0; // Add speed variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.deepPurple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (bdata == "START") {
                      bdata = "STOP";
                      _startLocationUpdates();
                    } else {
                      bdata = "START";
                      _stopLocationUpdates();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 10,
                ),
                child: Text(
                  bdata,
                  style: const TextStyle(
                    fontSize: 40,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('location')
                    .doc('location')
                    .snapshots(),
                builder: (context, snapshot) {
                  // ... (error and waiting state handling) ...

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text("No location data found.",
                        style: TextStyle(color: Colors.white));
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final firestoreLocation =
                      data['Location'] as String ?? 'No Location';
                  final firestoreSpeed =
                      data['Speed'] as double? ?? 0.0; // Fetch speed

                  return Column(
                    children: [
                      Text(
                        'Firestore Location: $firestoreLocation',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Speed: ${_formatSpeedToKMPH(firestoreSpeed)}', // Display speed
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSpeedToKMPH(double speedInMetersPerSecond) {
    double speedInKMH = speedInMetersPerSecond * 3.6;
    return '${speedInKMH.toStringAsFixed(2)} km/h';
  }

  void _startLocationUpdates() {
    _isUpdatingLocation = true;
    _getCurrentLocation(); // Get initial location immediately

    _locationUpdateTimer =
        Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (_isUpdatingLocation) {
        _getCurrentLocation();
      } else {
        timer.cancel();
      }
    });
  }

  void _stopLocationUpdates() {
    _isUpdatingLocation = false;
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorDialog('Location services are disabled.');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorDialog('Location permission denied.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showErrorDialog(
          'Location permissions are permanently denied, please enable them in settings.');
      return null;
    }

    try {
      LocationSettings locationSettings;

      if (defaultTargetPlatform == TargetPlatform.android) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          forceLocationManager: true,
        );
      } else {
        locationSettings = LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        );
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      double currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
      double timeDifference = currentTime - _lastUpdateTime;

      double distanceThreshold = 0.1;

      if (Geolocator.distanceBetween(_previousLatitude, _previousLongitude,
                  position.latitude, position.longitude) >
              distanceThreshold ||
          !locationInitialized) {
        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
          _speed = position.speed; // Get speed from Position object
        });

        _updateLocationInFirestore(
            latitude, longitude, _speed); // Update Firestore with speed

        _previousLatitude = position.latitude;
        _previousLongitude = position.longitude;
        locationInitialized = true;
        _lastUpdateTime = currentTime;
      }

      return position;
    } catch (e) {
      _showSnackBar("Error getting current location: $e");
      return null;
    }
  }

  Future<void> _updateLocationInFirestore(
      double lat, double lon, double speed) async {
    try {
      await FirebaseFirestore.instance
          .collection('location')
          .doc('location')
          .set({
        'Location': '$lat° N, $lon° E',
        'Speed': speed, // Save speed to Firestore
      });
      _showSnackBar("Location and Speed updated in Firestore!");
    } catch (e) {
      _showSnackBar("Error updating Firestore data: $e");
      print("Error updating Firestore data: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _stopLocationUpdates();
    super.dispose();
  }
}
