// widgets/bus_list_widget.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anavandi_locator/functions/hexagon_painter.dart';
import 'package:anavandi_locator/screen/bus_route_map_page.dart';

class BusListWidget extends StatelessWidget {
  final List<DocumentSnapshot> busList;

  const BusListWidget({super.key, required this.busList});

  Future<DocumentSnapshot?> _fetchAssignDataDocument(
    String busRegistrationNumber,
  ) async {
    try {
      QuerySnapshot assignDataQuery =
          await FirebaseFirestore.instance
              .collection('assignData')
              .where(
                'busRegistrationNumber',
                isEqualTo: busRegistrationNumber,
              ) // Assuming 'busRegistrationNumber' links assignData and busData
              .limit(1)
              .get();

      if (assignDataQuery.docs.isNotEmpty) {
        return assignDataQuery.docs.first;
      } else {
        print(
          'BusListWidget: No assignData document found for busRegistrationNumber: $busRegistrationNumber',
        );
        return null;
      }
    } catch (e) {
      print('BusListWidget: Error fetching assignData document: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return busList.isNotEmpty
        ? ListView.builder(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: busList.length,
          itemBuilder: (context, index) {
            DocumentSnapshot busData =
                busList[index]; // busData document from busList
            Map<String, dynamic> data = busData.data() as Map<String, dynamic>;
            return InkWell(
              onTap: () async {
                // Make onTap async
                DocumentSnapshot? assignDataDocument =
                    await _fetchAssignDataDocument(
                      data['busRegistrationNumber'],
                    ); // Fetch assignData

                if (assignDataDocument != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BusRouteMapPage(
                            startingPointName: data['startingPoint'] ?? 'N/A',
                            endingPointName: data['endingPoint'] ?? 'N/A',
                            busRegistrationNumber:
                                data['busRegistrationNumber'] ?? 'N/A',
                            assignDataDocument:
                                assignDataDocument, // Pass assignDataDocument - **EDITED: ADDED**
                            busDataDocument: busData, // Pass busData document
                          ),
                    ),
                  );
                } else {
                  // Handle case where assignDataDocument is not found (optional - maybe show an error message)
                  print(
                    'BusListWidget: assignDataDocument not found, cannot navigate to BusRouteMapPage',
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
                                  '${data['startingPoint'] ?? 'N/A'} - ${data['endingPoint'] ?? 'N/A'}',
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
                                    text: data['busType'] ?? 'N/A',
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                      vertical: 6.0,
                                    ),
                                    child: Text(
                                      data['busType'] ?? 'N/A',
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
                                  data['busRegistrationNumber'] ?? 'N/A',
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
                                  data['depoName'] ?? 'N/A',
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
                                  '${data['startingTime'] ?? 'N/A'} - ${data['endingTime'] ?? 'N/A'}',
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
