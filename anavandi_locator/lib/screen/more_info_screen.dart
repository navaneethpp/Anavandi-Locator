// lib/screen/more_info_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MoreInfoScreen extends StatelessWidget {
  final DocumentSnapshot assignDataDocument; // Rename to assignDataDocument
  final DocumentSnapshot busDataDocument; // Add busDataDocument

  const MoreInfoScreen({
    super.key,
    required this.assignDataDocument, // Rename here as well
    required this.busDataDocument, // Add busDataDocument here
  });

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> assignData =
        assignDataDocument.data()
            as Map<String, dynamic>; // Data from assignData
    // Map<String, dynamic> busData =
    //     busDataDocument.data() as Map<String, dynamic>; // Data from busData

    return Scaffold(
      appBar: AppBar(title: const Text('Bus Route Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              'Bus Route',
              '${assignData['startingPoint'] ?? 'N/A'} - ${assignData['endingPoint'] ?? 'N/A'}',
            ),
            _buildDetailRow('Bus Type', assignData['busType'] ?? 'N/A'),
            _buildDetailRow(
              'Registration Number',
              assignData['busRegistrationNumber'] ?? 'N/A',
            ),
            _buildDetailRow('Depot Name', assignData['depoName'] ?? 'N/A'),
            _buildDetailRow(
              'Starting Time',
              assignData['startingTime'] ?? 'N/A',
            ),
            _buildDetailRow('Ending Time', assignData['endingTime'] ?? 'N/A'),
            // Removed _buildDetailRow('Bus Model', busData['busModel'] ?? 'N/A'), // Bus Model Row - REMOVED
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16.0),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
