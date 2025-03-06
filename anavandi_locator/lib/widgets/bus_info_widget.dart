// widgets/bus_info_widget.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anavandi_locator/screen/bus_route_map_page.dart';

class BusInfoWidget extends StatelessWidget {
  final DocumentSnapshot busDocument;

  const BusInfoWidget({super.key, required this.busDocument});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> busData = busDocument.data() as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bus ${busData['busRegistrationNumber'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Trip ID: ${busData['tripId'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 14.0),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                const Icon(Icons.directions_bus, color: Colors.blueGrey),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Route: ${busData['startingPoint'] ?? 'N/A'} to ${busData['endingPoint'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blueGrey),
                const SizedBox(width: 8.0),
                Text(
                  'Driver: ${busData['driverName'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.person_outline, color: Colors.blueGrey),
                const SizedBox(width: 8.0),
                Text(
                  'Conductor: ${busData['conductorName'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            const SizedBox(height: 15.0),
            Align(
              alignment: Alignment.bottomRight,
              child: FilledButton(
                onPressed: () async {
                  DocumentSnapshot<Map<String, dynamic>> busDataDocument =
                      await FirebaseFirestore.instance
                          .collection('busData')
                          .doc(busData['busRegistrationNumber'])
                          .get();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BusRouteMapPage(
                            startingPointName:
                                busData['startingPoint'] ?? 'N/A',
                            endingPointName: busData['endingPoint'] ?? 'N/A',
                            busRegistrationNumber:
                                busData['busRegistrationNumber'] ?? 'N/A',
                            assignDataDocument: busDocument,
                            busDataDocument: busDataDocument,
                          ),
                    ),
                  );
                },
                child: const Text('Track Bus'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
