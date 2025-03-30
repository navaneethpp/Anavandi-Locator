import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anavandi_locator/data/models/bus_route.dart'; // Import the new model

class HomeSubmitHandler {
  static Future<void> handleSubmit(
    BuildContext context,
    TextEditingController startingPointController,
    TextEditingController destinationController,
    Function(List<BusRoute>)
    onRouteFound, // Callback to send a list of BusRoute
  ) async {
    // Hide the keyboard
    FocusScope.of(context).unfocus();

    final startPoint = startingPointController.text.trim();
    final destination = destinationController.text.trim();

    if (startPoint.isEmpty || destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both starting point and destination.'),
        ),
      );
      return;
    }

    if (startPoint == destination) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Invalid Input'),
            content: const Text(
              'Starting point and destination cannot be the same.',
            ),
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
      return;
    }

    try {
      final assignDataCollection = FirebaseFirestore.instance.collection(
        'assignData',
      );
      final querySnapshot = await assignDataCollection.get();

      List<BusRoute> foundRoutes = [];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('busStops') && data['busStops'] is List) {
          final busStopsData = data['busStops'] as List<dynamic>;
          int startIndex = -1;
          int destinationIndex = -1;
          List<BusStop> currentBusStops = [];
          String? busRegistrationNumber; // Initialize

          if (data.containsKey('busRegistrationNumber')) {
            busRegistrationNumber = data['busRegistrationNumber'] as String?;
          }

          for (final stopData in busStopsData) {
            if (stopData is Map &&
                stopData.containsKey('stopName') &&
                stopData.containsKey('stopTime')) {
              currentBusStops.add(
                BusStop.fromJson(stopData as Map<String, dynamic>),
              );
            }
          }

          for (int i = 0; i < currentBusStops.length; i++) {
            if (currentBusStops[i].stopName.trim() == startPoint) {
              startIndex = i;
            }
            if (currentBusStops[i].stopName.trim() == destination) {
              destinationIndex = i;
            }
          }

          if (startIndex != -1 &&
              destinationIndex != -1 &&
              startIndex < destinationIndex) {
            final routeBusStops = currentBusStops.sublist(
              startIndex,
              destinationIndex + 1,
            );

            final newRoute = BusRoute(
              startingPoint: data['startingPoint'] as String? ?? '',
              endingPoint: data['endingPoint'] as String? ?? '',
              startingTime: data['startingTime'] as String? ?? '',
              endingTime: data['endingTime'] as String? ?? '',
              busType: data['busType'] as String? ?? '',
              busRegistrationNumber:
                  busRegistrationNumber ??
                  'N/A', // Use the fetched or default value
              routeId: data['routeId'] as String? ?? '',
              tripId: data['tripId'] as String? ?? '',
              busStops: routeBusStops,
            );
            foundRoutes.add(newRoute);
            // REMOVE THIS LINE: break;
          }
        }
      }

      onRouteFound(foundRoutes); // Send the list of BusRoute objects
    } catch (e) {
      print('Error searching for route: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error searching for route. Please try again.'),
        ),
      );
    }
  }
}
