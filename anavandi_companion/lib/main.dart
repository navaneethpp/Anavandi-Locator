import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      title: 'Bus Location Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Bus Location Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _buttonText = "START";
  double _latitude = 0.0;
  double _longitude = 0.0;
  double _previousLatitude = 0.0;
  double _previousLongitude = 0.0;
  bool _locationInitialized = false;
  Timer? _locationUpdateTimer;
  bool _isUpdatingLocation = false;
  double _lastUpdateTime = 0;
  double _speed = 0.0;
  List<String> _busList = [];
  String? _selectedBusUniqueNumber;

  @override
  void initState() {
    super.initState();
    _fetchBusList();
  }

  Future<void> _fetchBusList() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('busData').get();
      List<String> busUniqueNumbers = snapshot.docs
          .map((doc) => doc.data()['busUniqueNumber'] as String)
          .toList();
      setState(() {
        _busList = busUniqueNumbers;
        if (_busList.isNotEmpty) {
          _selectedBusUniqueNumber = _busList[0];
        }
      });
    } catch (e) {
      _showSnackBar("Error fetching bus list: $e");
      print("Error fetching bus list: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (_busList.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: _selectedBusUniqueNumber,
                    decoration: InputDecoration(
                      labelText: 'Select Bus',
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    dropdownColor: Colors.indigoAccent,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    items: _busList.map((String busUniqueNumber) {
                      return DropdownMenuItem<String>(
                        value: busUniqueNumber,
                        child: Text(busUniqueNumber),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedBusUniqueNumber = newValue;
                      });
                    },
                  )
                else
                  const Text(
                    "Loading Buses...",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_buttonText == "START") {
                        _buttonText = "STOP";
                        if (_selectedBusUniqueNumber != null) {
                          _startLocationUpdates();
                        } else {
                          _showSnackBar(
                              "Please select a bus from the dropdown.");
                        }
                      } else {
                        _buttonText = "START";
                        _stopLocationUpdates();
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                  ),
                  child: Text(
                    _buttonText,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Last Latitude: ${_latitude.toStringAsFixed(6)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  'Last Longitude: ${_longitude.toStringAsFixed(6)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  'Speed: ${_formatSpeedToKMPH(_speed)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 30),
              ],
            ),
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
    setState(() {
      _speed = 0.0;
    });
    _updateLocationInFirestore(_latitude, _longitude, _speed);
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
          !_locationInitialized) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          // Apply speed threshold here:
          _speed = position.speed < 0.1 / 3.6
              ? 0.0
              : position.speed; // Threshold at 0.1 km/h (in m/s)
        });

        _updateLocationInFirestore(_latitude, _longitude, _speed);

        _previousLatitude = position.latitude;
        _previousLongitude = position.longitude;
        _locationInitialized = true;
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
    if (_selectedBusUniqueNumber == null) {
      _showSnackBar("No bus selected!");
      return;
    }
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('busData')
          .where('busUniqueNumber', isEqualTo: _selectedBusUniqueNumber)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _showSnackBar("Bus document not found for: $_selectedBusUniqueNumber");
        print("Bus document not found for: $_selectedBusUniqueNumber");
        return;
      }

      String documentIdToUpdate = querySnapshot.docs.first.id;

      // Apply speed threshold again here before sending to Firestore (optional, but consistent):
      double speedToSend =
          speed < 0.1 / 3.6 ? 0.0 : speed * 3.6; // Threshold before sending

      await FirebaseFirestore.instance
          .collection('busData')
          .doc(documentIdToUpdate)
          .update({
        'location': [lat, lon],
        'speed': speedToSend, // Send thresholded speed to Firestore in km/h
      });
      _showSnackBar(
          "Location and Speed updated for Bus: $_selectedBusUniqueNumber in Firestore!");
    } catch (e) {
      _showSnackBar(
          "Error updating Firestore data for Bus: $_selectedBusUniqueNumber: $e");
      print(
          "Error updating Firestore data for Bus: $_selectedBusUniqueNumber: $e");
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
