// more_info_screen.dart

import 'package:anavandi_locator/widgets/textForBusDetails.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:anavandi_locator/api/open_cage_geocoder_api.dart';
import 'package:intl/intl.dart'; // For time formatting

class Coordinates {
  final double latitude;
  final double longitude;
  Coordinates(this.latitude, this.longitude);
}

class MoreInfoScreen extends StatefulWidget {
  final String registrationNumber;
  final String uniqueNumber;
  final String startingStation;
  final String endingStation;
  final String currentLocation;
  final String arrivingTime;
  final String busType;
  final String userStartingStation;
  final String userEndingStation;
  final double endLatitude; // Add destination latitude
  final double endLongitude; // Add destination longitude

  const MoreInfoScreen({
    super.key,
    required this.registrationNumber,
    required this.uniqueNumber,
    required this.startingStation,
    required this.endingStation,
    required this.currentLocation,
    required this.arrivingTime,
    required this.busType,
    required this.userStartingStation,
    required this.userEndingStation,
    required this.endLatitude, // Add to constructor
    required this.endLongitude, // Add to constructor
  });

  @override
  State<MoreInfoScreen> createState() => _MoreInfoScreenState();
}

class _MoreInfoScreenState extends State<MoreInfoScreen> {
  String _currentBusLocationName = '';
  Coordinates? _lastCoordinates;
  String _predictedArrivalTime = 'Calculating...';
  double _currentBusSpeed = 0.0; // State variable for bus speed

  // No longer using average bus speed constant

  @override
  void initState() {
    super.initState();
    _currentBusLocationName = widget.currentLocation;
    _listenToBusLocationUpdates();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _listenToBusLocationUpdates() {
    FirebaseFirestore.instance
        .collection('location')
        .doc('location')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('Location') && data.containsKey('Speed')) {
          // Check for both Location and Speed
          final locationString = data['Location'] as String;
          final coordinates = _extractCoordinates(locationString);
          final speedFromFirestore =
              data['Speed'] as num? ?? 0.0; // Get speed from Firestore

          if (coordinates != null) {
            _updateLocationNameIfNeeded(coordinates);
            setState(() {
              _currentBusSpeed =
                  speedFromFirestore.toDouble(); // Update speed state
            });
            _updateArrivalTimePrediction(
                coordinates, _currentBusSpeed); // Pass speed to prediction
          }
        }
      }
    });
  }

  Coordinates? _extractCoordinates(String locationString) {
    try {
      final parts = locationString.split(RegExp(r',\s*'));
      if (parts.length != 2) return null;

      final latitudeString = parts[0].replaceAll(RegExp(r'[\u00B0N]'), '');
      final longitudeString = parts[1].replaceAll(RegExp(r'[\u00B0E]'), '');

      final latitude = double.parse(latitudeString);
      final longitude = double.parse(longitudeString);

      return Coordinates(latitude, longitude);
    } catch (e) {
      print("Error parsing coordinates: $e, String: $locationString");
      return null;
    }
  }

  Future<String> _getLocationNameFromCoordinates(
      Coordinates coordinates) async {
    const apiKey = openCageGeoCodingAPI;
    final latitude = coordinates.latitude;
    final longitude = coordinates.longitude;
    final apiUrl =
        'https://api.opencagedata.com/geocode/v1/json?q=$latitude+$longitude&key=$apiKey&pretty=1&no_annotations=1';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final formattedAddress = data['results'][0]['formatted'];
          return formattedAddress ?? 'Location name not found';
        } else {
          return 'Location name not found';
        }
      } else {
        print(
            'Reverse geocoding failed with status code: ${response.statusCode}');
        return 'Error fetching location name';
      }
    } catch (e) {
      print('Error during reverse geocoding: $e');
      return 'Error fetching location name';
    }
  }

  Future<void> _updateLocationNameIfNeeded(Coordinates newCoordinates) async {
    if (_lastCoordinates == null ||
        _isSignificantLocationChange(newCoordinates, _lastCoordinates!)) {
      String locationName =
          await _getLocationNameFromCoordinates(newCoordinates);
      setState(() {
        _currentBusLocationName = locationName;
        _lastCoordinates = newCoordinates;
      });
    }
  }

  bool _isSignificantLocationChange(Coordinates coord1, Coordinates coord2) {
    const double threshold = 0.0005;

    final latDiff = (coord1.latitude - coord2.latitude).abs();
    final longDiff = (coord1.longitude - coord2.longitude).abs();

    return latDiff > threshold || longDiff > threshold;
  }

  Future<void> _updateArrivalTimePrediction(
      Coordinates currentCoordinates, double currentSpeedMps) async {
    // Added speed parameter
    // Get destination coordinates from widget parameters
    double destinationLatitude = widget.endLatitude;
    double destinationLongitude = widget.endLongitude;

    if (destinationLatitude == null || destinationLongitude == null) {
      setState(() {
        _predictedArrivalTime = 'Destination location missing';
      });
      return;
    }

    // Calculate distance to destination
    double distanceInMeters = Geolocator.distanceBetween(
      currentCoordinates.latitude,
      currentCoordinates.longitude,
      destinationLatitude,
      destinationLongitude,
    );

    double distanceInKilometers = distanceInMeters / 1000;

    // Use current speed from Firestore for prediction
    double currentSpeedKmph = currentSpeedMps * 3.6; // Convert m/s to km/h

    // Calculate estimated time in hours based on CURRENT speed
    double timeInHours = 0; // Initialize to 0 to avoid potential issues
    if (currentSpeedKmph > 0) {
      // Avoid division by zero
      timeInHours = distanceInKilometers / currentSpeedKmph;
    }

    if (timeInHours.isNaN || timeInHours.isInfinite) {
      setState(() {
        _predictedArrivalTime = 'Calculating...'; // Or handle error as needed
      });
      return;
    }

    // Format time for display
    String formattedArrivalTime;
    if (timeInHours < 1) {
      int minutes = (timeInHours * 60).round();
      formattedArrivalTime = '$minutes minutes';
    } else {
      int hours = timeInHours.floor();
      int minutes = ((timeInHours - hours) * 60).round();
      formattedArrivalTime = '$hours hours $minutes minutes';
    }

    setState(() {
      _predictedArrivalTime = formattedArrivalTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('More Bus Info'),
            Image.asset(
              'assets/logo.png',
              width: 100,
              height: 40,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextForBusDetails(
              labelText: 'Registration Number:',
              dataText: widget.registrationNumber,
            ),
            const SizedBox(height: 10),
            TextForBusDetails(
              labelText: 'Unique Number:',
              dataText: widget.uniqueNumber,
            ),
            const SizedBox(height: 10),
            TextForBusDetails(
              labelText: 'Your Starting Station:',
              dataText: widget.userStartingStation,
            ),
            const SizedBox(height: 10),
            TextForBusDetails(
              labelText: 'Your Destination:',
              dataText: widget.userEndingStation,
            ),
            const SizedBox(height: 10),
            TextForBusDetails(
              labelText: 'Bus Starting Station:',
              dataText: widget.startingStation,
            ),
            const SizedBox(height: 10),
            TextForBusDetails(
              labelText: 'Bus Ending Station:',
              dataText: widget.endingStation,
            ),
            const SizedBox(height: 10),
            TextForBusDetails(
              labelText: 'Current Location:',
              dataText: _currentBusLocationName,
            ),
            const SizedBox(height: 10),
            TextForBusDetails(
              labelText: 'Current Speed:', // Display current speed
              dataText: '${_currentBusSpeed.toStringAsFixed(2)} m/s',
            ),
            const SizedBox(height: 10),
            TextForBusDetails(
              labelText:
                  'Predicted Arrival Time to Destination:', // New Predicted Arrival Time Label
              dataText: _predictedArrivalTime, // Display predicted time
            ),
            const SizedBox(height: 10),
            TextForBusDetails(
              labelText: 'Bus Type:',
              dataText: widget.busType,
            ),
          ],
        ),
      ),
    );
  }
}
