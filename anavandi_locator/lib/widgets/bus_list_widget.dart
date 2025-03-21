// widgets/bus_list_widget.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anavandi_locator/functions/hexagon_painter.dart';
import 'package:anavandi_locator/screen/bus_route_map_page.dart';
import 'package:intl/intl.dart'; // Import intl package for title case

class BusListWidget extends StatelessWidget {
  final List<DocumentSnapshot> busList;

  const BusListWidget({super.key, required this.busList});

  Future<DocumentSnapshot?> _fetchBusDataDocument(
    String busRegistrationNumber,
  ) async {
    try {
      QuerySnapshot busDataQuery =
          await FirebaseFirestore.instance
              .collection('busData')
              .where('busRegistrationNumber', isEqualTo: busRegistrationNumber)
              .limit(1)
              .get();

      if (busDataQuery.docs.isNotEmpty) {
        return busDataQuery.docs.first;
      } else {
        print(
          'BusListWidget: No busData document found for busRegistrationNumber: $busRegistrationNumber',
        );
        return null;
      }
    } catch (e) {
      print('BusListWidget: Error fetching busData document: $e');
      return null;
    }
  }

  // Helper function to title case a string
  String _toTitleCase(String text) {
    if (text.isEmpty) {
      return 'N/A'; // Or handle null/empty as needed
    }
    return toBeginningOfSentenceCase(text) ?? text;
  }

  @override
  Widget build(BuildContext context) {
    return busList.isNotEmpty
        ? ListView.builder(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: busList.length,
          itemBuilder: (context, index) {
            DocumentSnapshot assignDataDocument =
                busList[index]; // This is an assignData document
            Map<String, dynamic> assignData =
                assignDataDocument.data() as Map<String, dynamic>;
            return InkWell(
              onTap: () async {
                // Make onTap async
                final String busRegistrationNumber =
                    assignData['busRegistrationNumber'];
                DocumentSnapshot? busDataDocument = await _fetchBusDataDocument(
                  busRegistrationNumber,
                ); // Fetch the actual busData document

                if (busDataDocument != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BusRouteMapPage(
                            startingPointName:
                                assignData['startingPoint'] ?? 'N/A',
                            endingPointName: assignData['endingPoint'] ?? 'N/A',
                            busRegistrationNumber: busRegistrationNumber,
                            assignDataDocument: assignDataDocument,
                            busDataDocument:
                                busDataDocument, // Pass the fetched busData document
                          ),
                    ),
                  );
                } else {
                  // Handle case where busDataDocument is not found
                  print(
                    'BusListWidget: busDataDocument not found for registration: $busRegistrationNumber',
                  );
                  // You might want to show a snackbar or dialog to inform the user
                }
              },
              child: Card(
                elevation: 3.0,
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 5.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Bus Route',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey[600],
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                                Text(
                                  // Apply title case here
                                  '${_toTitleCase(assignData['startingPoint'])} - ${_toTitleCase(assignData['endingPoint'])}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomPaint(
                                  painter: HexagonPainter(
                                    text: assignData['busType'] ?? 'N/A',
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                      vertical: 6.0,
                                    ),
                                    child: Text(
                                      assignData['busType'] ?? 'N/A',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Registration Number',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey[600],
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                                Text(
                                  assignData['busRegistrationNumber'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      Divider(color: Colors.grey[300], thickness: 1.0),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Depot Name',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey[600],
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                                Text(
                                  assignData['depoName'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.0,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Starting Time - Ending Time',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey[600],
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                                Text(
                                  '${assignData['startingTime'] ?? 'N/A'} - ${assignData['endingTime'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.0,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        )
        : const Text(
          'Not found any buses',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0),
        );
  }
}
