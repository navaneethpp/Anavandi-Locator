// BusDetailsPage.dart

import 'package:flutter/material.dart';

import 'map.dart';
import 'textForBusDetails.dart';

class BusDetailsPage extends StatelessWidget {
  final String registrationNumber;
  final String uniqueNumber;
  final String startingStation;
  final String endingStation;
  final String currentLocation;
  final String arrivingTime;
  final String busType;

  const BusDetailsPage({
    super.key,
    required this.registrationNumber,
    required this.uniqueNumber,
    required this.startingStation,
    required this.endingStation,
    required this.currentLocation,
    required this.arrivingTime,
    required this.busType,
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
          const Positioned.fill(child: MapWidget()),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextForBusDetails(
                    label: 'Registration Number: $registrationNumber',
                    isBold: true,
                  ),
                  const SizedBox(height: 10),
                  TextForBusDetails(
                    label: 'Unique Number: $uniqueNumber',
                    isBold: true,
                  ),
                  const SizedBox(height: 10),
                  TextForBusDetails(
                    label: 'Current Location: $currentLocation',
                    isBold: true,
                  ),
                  const SizedBox(height: 10),
                  TextForBusDetails(
                    label: 'Arriving Time: $arrivingTime',
                    isBold: true,
                  ),
                  const SizedBox(height: 10),
                  TextForBusDetails(
                    label: 'Bus Type: $busType',
                    isBold: true,
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
}

class MoreInfoScreen extends StatelessWidget {
  final String registrationNumber;
  final String uniqueNumber;
  final String startingStation;
  final String endingStation;
  final String currentLocation;
  final String arrivingTime;
  final String busType;

  const MoreInfoScreen({
    super.key,
    required this.registrationNumber,
    required this.uniqueNumber,
    required this.startingStation,
    required this.endingStation,
    required this.currentLocation,
    required this.arrivingTime,
    required this.busType,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextForBusDetails(
                label: 'Registration Number: $registrationNumber'),
            const SizedBox(height: 10),
            TextForBusDetails(label: 'Unique Number: $uniqueNumber'),
            const SizedBox(height: 10),
            TextForBusDetails(label: 'Starting Station: $startingStation'),
            const SizedBox(height: 10),
            TextForBusDetails(label: 'Ending Station: $endingStation'),
            const SizedBox(height: 10),
            TextForBusDetails(label: 'Current Location: $currentLocation'),
            const SizedBox(height: 10),
            TextForBusDetails(label: 'Arriving Time: $arrivingTime'),
            const SizedBox(height: 10),
            TextForBusDetails(label: 'Bus Type: $busType'),
            // Add more detailed information here,
            // e.g., driver name, contact number,
            // seating capacity, etc.
          ],
        ),
      ),
    );
  }
}
