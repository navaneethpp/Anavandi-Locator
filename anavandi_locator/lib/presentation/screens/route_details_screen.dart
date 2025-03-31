import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart'; // Import latlong2 for coordinate calculations
import 'package:geolocator/geolocator.dart'; // For calculating distances
import 'dart:async'; // For Timer

class RouteDetailsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> stopsData;
  final String startPoint;
  final String destinationPoint;
  final LatLng? initialBusLocation; // Use initial location, will be updated
  final Stream<LatLng?> busLocationStream; // Receive a stream of bus locations

  const RouteDetailsScreen({
    super.key,
    required this.stopsData,
    required this.startPoint,
    required this.destinationPoint,
    this.initialBusLocation,
    required this.busLocationStream,
  });

  @override
  State<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  int? _currentStopIndex;
  LatLng? _currentBusLocation;
  StreamSubscription<LatLng?>? _busLocationSubscription;

  @override
  void initState() {
    super.initState();
    _currentBusLocation = widget.initialBusLocation;
    _findCurrentStop();
    _busLocationSubscription = widget.busLocationStream.listen((newLocation) {
      if (newLocation != null) {
        setState(() {
          _currentBusLocation = newLocation;
          _findCurrentStop();
        });
      }
    });
  }

  @override
  void dispose() {
    _busLocationSubscription?.cancel();
    super.dispose();
  }

  // Function to calculate the distance between two coordinates
  double _calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  void _findCurrentStop() {
    if (_currentBusLocation == null || widget.stopsData.isEmpty) {
      return;
    }

    double minDistance = double.infinity;
    int closestStopIndex = -1;

    for (int i = 0; i < widget.stopsData.length; i++) {
      final stop = widget.stopsData[i];
      final stopLatitude = stop['latitude'];
      final stopLongitude = stop['longitude'];

      if (stopLatitude is num && stopLongitude is num) {
        final stopLocation = LatLng(
          stopLatitude.toDouble(),
          stopLongitude.toDouble(),
        );
        final distance = _calculateDistance(_currentBusLocation!, stopLocation);

        if (distance < minDistance) {
          minDistance = distance;
          closestStopIndex = i;
        }
      }
    }

    if (mounted) {
      setState(() {
        _currentStopIndex = closestStopIndex != -1 ? closestStopIndex : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.startPoint} to ${widget.destinationPoint} Route'),
      ),
      body:
          widget.stopsData.isEmpty
              ? const Center(child: Text('No stop details available.'))
              : ListView.builder(
                itemCount: widget.stopsData.length,
                itemBuilder: (context, index) {
                  final stop = widget.stopsData[index];
                  final isCurrentStop = index == _currentStopIndex;
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    color: isCurrentStop ? Colors.yellow[100] : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stop['stopName'] ?? 'Stop Name Not Available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isCurrentStop ? Colors.black87 : null,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                if (stop['arrivalTime'] != null)
                                  Text(
                                    'Arrival: ${stop['arrivalTime']}',
                                    style: TextStyle(
                                      color:
                                          isCurrentStop ? Colors.black54 : null,
                                    ),
                                  ),
                                if (stop['departureTime'] != null)
                                  Text(
                                    'Departure: ${stop['departureTime']}',
                                    style: TextStyle(
                                      color:
                                          isCurrentStop ? Colors.black54 : null,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (stop['stopTime'] != null)
                            Text(
                              stop['stopTime'],
                              style: TextStyle(
                                fontSize: 16,
                                color: isCurrentStop ? Colors.black87 : null,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
