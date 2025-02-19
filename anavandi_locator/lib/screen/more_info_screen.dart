// more_info_screen.dart

import 'package:anavandi_locator/widgets/textForBusDetails.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:anavandi_locator/api/open_cage_geocoder_api.dart';

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
  });

  @override
  State<MoreInfoScreen> createState() => _MoreInfoScreenState();
}

class _MoreInfoScreenState extends State<MoreInfoScreen> {
  String _currentBusLocationName = '';
  Coordinates? _lastCoordinates;

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
        if (data.containsKey('Location')) {
          final locationString = data['Location'] as String;
          final coordinates = _extractCoordinates(locationString);
          if (coordinates != null) {
            _updateLocationNameIfNeeded(coordinates);
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
              labelText: 'Registration Number:', // Label is now separate
              dataText: widget.registrationNumber, // Data is separate
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
              dataText: _currentBusLocationName, // Dynamic location name
            ),
            const SizedBox(height: 10),
            TextForBusDetails(
              labelText: 'Arriving Time:',
              dataText: widget.arrivingTime,
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
