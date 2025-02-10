import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import 'dart:async';

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
  double previousLatitude = 0.0;
  double previousLongitude = 0.0;
  bool locationInitialized = false;
  Timer? _locationUpdateTimer;
  bool _isUpdatingLocation = false;

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
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text("No location data found.",
                        style: TextStyle(color: Colors.white));
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final firestoreLocation = data['Location'] as String;

                  return Text(
                    'Firestore Location: $firestoreLocation',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startLocationUpdates() {
    _isUpdatingLocation = true;
    _getCurrentLocation(); // Get initial location immediately

    _locationUpdateTimer =
        Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_isUpdatingLocation) {
        _getCurrentLocation();
      } else {
        timer.cancel(); // Stop the timer if the flag is false
      }
    });
  }

  void _stopLocationUpdates() {
    _isUpdatingLocation = false;
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorDialog('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorDialog('Location permission denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showErrorDialog(
          'Location permissions are permanently denied, please enable them in settings.');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      double currentLatRad = _degreesToRadians(position.latitude);
      double currentLonRad = _degreesToRadians(position.longitude);
      double previousLatRad = _degreesToRadians(previousLatitude);
      double previousLonRad = _degreesToRadians(previousLongitude);

      double distance = Geolocator.distanceBetween(
          previousLatRad, previousLonRad, currentLatRad, currentLonRad);

      const double minimumDistanceChange = 10;

      if (distance > minimumDistanceChange || !locationInitialized) {
        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
        });

        _updateLocationInFirestore(latitude, longitude);

        previousLatitude = position.latitude;
        previousLongitude = position.longitude;
        locationInitialized = true;
      } else {
        _showSnackBar("No significant location change");
      }
    } catch (e) {
      _showSnackBar("Error getting current location: $e");
      print("Error getting current location: $e");
    }
  }

  Future<void> _updateLocationInFirestore(double lat, double lon) async {
    try {
      await FirebaseFirestore.instance
          .collection('location')
          .doc('location')
          .set({'Location': '$lat° N, $lon° E'});
      _showSnackBar("Location updated in Firestore!");
    } catch (e) {
      _showSnackBar("Error updating Firestore data: $e");
      print("Error updating Firestore data: $e");
    }
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
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
