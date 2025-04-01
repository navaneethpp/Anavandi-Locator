import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:anavandi_locator/presentation/widgets/current_bus_stop.dart';
import 'package:anavandi_locator/presentation/widgets/detail_item.dart';

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
                DetailItem(
                  label: 'Bus Registration Number',
                  value: data['busRegistrationNumber']?.toString(),
                ),
                DetailItem(
                  label: 'Bus Type',
                  value: data['busType']?.toString(),
                ),
                DetailItem(
                  label: 'Driver Name',
                  value: data['driverName']?.toString(),
                ),
                DetailItem(
                  label: 'Conductor Name',
                  value: data['conductorName']?.toString(),
                ),
                DetailItem(
                  label: 'Depo Name',
                  value: data['depoName']?.toString(),
                ),
                DetailItem(
                  label: 'Starting Point',
                  value: data['startingPoint']?.toString(),
                ),
                DetailItem(
                  label: 'Ending Point',
                  value: data['endingPoint']?.toString(),
                ),
                CurrentBusStop(
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
}
