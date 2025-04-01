import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:anavandi_locator/presentation/widgets/current_bus_stop.dart'; // Import the new widget

class TripDetailsScreen extends StatelessWidget {
  final String tripId;
  final Stream<LatLng?> busLocationStream;
  final List<Map<String, dynamic>> stopsData;

  const TripDetailsScreen({
    super.key,
    required this.tripId,
    required this.busLocationStream,
    required this.stopsData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('assignData')
                .where('tripId', isEqualTo: tripId)
                .limit(1)
                .get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching data: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No trip details found.'));
          }

          final data =
              snapshot.data!.docs.first.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(child: Text('No trip details found.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem(
                  'Bus Registration Number',
                  data['busRegistrationNumber']?.toString(),
                ),
                _buildDetailItem('Bus Type', data['busType']?.toString()),
                _buildDetailItem('Driver Name', data['driverName']?.toString()),
                _buildDetailItem(
                  'Conductor Name',
                  data['conductorName']?.toString(),
                ),
                _buildDetailItem('Depo Name', data['depoName']?.toString()),
                _buildDetailItem(
                  'Starting Point',
                  data['startingPoint']?.toString(),
                ),
                _buildDetailItem(
                  'Ending Point',
                  data['endingPoint']?.toString(),
                ),
                CurrentBusStop(
                  // Use the new widget here
                  busLocationStream: busLocationStream,
                  stopsData: stopsData,
                ),
                // Add more fields if needed
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4.0),
          Text(value ?? 'Not Available'),
          const Divider(),
        ],
      ),
    );
  }
}
