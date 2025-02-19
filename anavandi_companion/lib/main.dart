import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:intl/intl.dart';

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
  double _speed = 0.0;
  List<String> _documentList =
      []; // List to hold document IDs in 'location' collection
  String? _selectedDocument; // Currently selected document ID

  @override
  void initState() {
    super.initState();
    _fetchDocumentList(); // Fetch document IDs from 'location' collection
  }

  Future<void> _fetchDocumentList() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('location')
          .get(); // Fetch from 'location' collection
      List<String> documentIds = snapshot.docs
          .map((doc) => doc.id)
          .toList(); // Document IDs are the names
      setState(() {
        _documentList = documentIds;
        if (_documentList.isNotEmpty) {
          _selectedDocument =
              _documentList[0]; // Select the first document by default
        }
      });
    } catch (e) {
      _showSnackBar("Error fetching document list: $e");
      print("Error fetching document list: $e");
    }
  }

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
              if (_documentList
                  .isNotEmpty) // Show dropdown only if document list is loaded
                DropdownButtonFormField<String>(
                  value: _selectedDocument,
                  decoration: InputDecoration(
                    labelText: 'Select Document', // Updated label
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  dropdownColor: Colors.deepPurpleAccent,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  items: _documentList.map((String documentId) {
                    // Use document IDs in dropdown
                    return DropdownMenuItem<String>(
                      value: documentId,
                      child: Text(documentId),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDocument = newValue;
                    });
                  },
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (bdata == "START") {
                      bdata = "STOP";
                      if (_selectedDocument != null) {
                        _startLocationUpdates();
                      } else {
                        _showSnackBar(
                            "Please select a document from the dropdown."); // Updated message
                      }
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
              if (_selectedDocument !=
                  null) // Show location data only when a document is selected
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('location')
                      .doc(_selectedDocument!) // Use selected document ID
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
                      return Text(
                          "No location data found for $_selectedDocument.", // Updated message
                          style: TextStyle(color: Colors.white));
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    String firestoreLocationString = 'No Location Data';
                    if (data.containsKey('Location') &&
                        data['Location'] is List) {
                      List<dynamic> locationArray =
                          data['Location'] as List<dynamic>;
                      if (locationArray.length == 2) {
                        double lat = locationArray[0] as double? ?? 0.0;
                        double lon = locationArray[1] as double? ?? 0.0;
                        firestoreLocationString =
                            '${lat.toStringAsFixed(6)}° N, ${lon.toStringAsFixed(6)}° E';
                      }
                    }

                    final firestoreSpeed = data['Speed'] as double? ?? 0.0;

                    return Column(
                      children: [
                        Text(
                          'Selected Document: $_selectedDocument', // Updated text
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          'Firestore Location: $firestoreLocationString',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Speed: ${_formatSpeedToKMPH(firestoreSpeed)}',
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
    _getCurrentLocation();

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
          _speed = position.speed;
        });

        _updateLocationInFirestore(latitude, longitude, _speed);

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
    if (_selectedDocument == null) {
      _showSnackBar("No document selected!");
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('location')
          .doc(_selectedDocument!)
          .update({
        // Use .update() to update existing document
        'Location': [lat, lon],
        'Speed': speed,
      });
      _showSnackBar(
          "Location and Speed updated for $_selectedDocument in Firestore!");
    } catch (e) {
      _showSnackBar("Error updating Firestore data for $_selectedDocument: $e");
      print("Error updating Firestore data for $_selectedDocument: $e");
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
