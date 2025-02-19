// BusDetailsPage.dart

import 'package:anavandi_locator/widgets/map.dart';
import 'package:anavandi_locator/widgets/textForBusDetails.dart';
import 'package:flutter/material.dart';
import 'more_info_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusDetailsPage extends StatelessWidget {
  final String registrationNumber;
  final String uniqueNumber;
  final String startingStation;
  final String endingStation;
  final String currentLocation;
  final String arrivingTime;
  final String busType;
  final double endLatitude;
  final double endLongitude;
  final String userStartingStation;
  final String userEndingStation;

  const BusDetailsPage({
    super.key,
    required this.registrationNumber,
    required this.uniqueNumber,
    required this.startingStation,
    required this.endingStation,
    required this.currentLocation,
    required this.arrivingTime,
    required this.busType,
    required this.endLatitude,
    required this.endLongitude,
    required this.userStartingStation,
    required this.userEndingStation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Bus Details'),
            Image.asset(
              'assets/logo.png',
              width: 100,
              height: 40,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FutureBuilder<Map<String, double>>(
              future: _fetchStartingDepotLocation(userStartingStation),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          'Error loading starting location: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final startLocation = snapshot.data!;
                  return MapWidget(
                    endLatitude: endLatitude,
                    endLongitude: endLongitude,
                    userStartLatitude: startLocation['latitude']!,
                    userStartLongitude: startLocation['longitude']!,
                  );
                } else {
                  return const Center(
                      child: Text('Could not load starting location'));
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextForBusDetails(
                    labelText: 'Registration Number:', // Changed to labelText
                    dataText: registrationNumber, // Added dataText
                  ),
                  const SizedBox(height: 10),
                  TextForBusDetails(
                    labelText: 'Unique Number:', // Changed to labelText
                    dataText: uniqueNumber, // Added dataText
                  ),
                  const SizedBox(height: 10),
                  TextForBusDetails(
                    labelText: 'Current Location:', // Changed to labelText
                    dataText: currentLocation, // Added dataText
                  ),
                  const SizedBox(height: 10),
                  TextForBusDetails(
                    labelText: 'Arriving Time:', // Changed to labelText
                    dataText: arrivingTime, // Added dataText
                  ),
                  const SizedBox(height: 10),
                  TextForBusDetails(
                    labelText: 'Bus Type:', // Changed to labelText
                    dataText: busType, // Added dataText
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MoreInfoScreen(
                      registrationNumber: registrationNumber,
                      uniqueNumber: uniqueNumber,
                      startingStation: startingStation,
                      endingStation: endingStation,
                      currentLocation: currentLocation,
                      arrivingTime: arrivingTime,
                      busType: busType,
                      userStartingStation: userStartingStation,
                      userEndingStation: userEndingStation,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.info),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, double>> _fetchStartingDepotLocation(
      String depotName) async {
    double? startLatitude;
    double? startLongitude;

    try {
      QuerySnapshot<Map<String, dynamic>> depotSnapshot =
          await FirebaseFirestore.instance
              .collection('Depot')
              .where('name', isEqualTo: depotName)
              .get();

      if (depotSnapshot.docs.isNotEmpty) {
        var depotData = depotSnapshot.docs.first.data();
        List<dynamic> locationArray = depotData['location'];
        if (locationArray.length == 2) {
          startLatitude = locationArray[0];
          startLongitude = locationArray[1];
        } else {
          throw Exception("Invalid location array format in Firestore");
        }
      } else {
        throw Exception("Depot '$depotName' not found in Firestore");
      }
    } catch (e) {
      print("Error fetching starting depot location: $e");
      throw Exception('Failed to load location for $depotName');
    }

    return {
      'latitude': startLatitude!,
      'longitude': startLongitude!,
    };
  }
}
