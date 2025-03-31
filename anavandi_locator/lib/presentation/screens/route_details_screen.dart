import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:anavandi_locator/utils/string_extensions.dart';
import 'dart:math' as math;

class RouteDetailsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> stopsData;
  final String startPoint;
  final String destinationPoint;
  final LatLng? initialBusLocation;
  final Stream<LatLng?> busLocationStream;

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
  LatLng? _currentBusLocation;
  int? _highlightedIndex;
  final double _proximityThreshold = 50; // Proximity in meters
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentBusLocation = widget.initialBusLocation;
    widget.busLocationStream.listen((location) {
      if (mounted && location != null) {
        setState(() {
          _currentBusLocation = location;
          _highlightCurrentStop();
        });
      }
    });
    _highlightCurrentStop();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double _calculateDistance(LatLng latlng1, double lat2, double lng2) {
    const R = 6371e3; // metres
    final lat1 = latlng1.latitude * math.pi / 180; // rad
    final lon1 = latlng1.longitude * math.pi / 180;
    final lat2Rad = lat2 * math.pi / 180;
    final lon2Rad = lng2 * math.pi / 180;
    final deltaLat = lat2Rad - lat1;
    final deltaLon = lon2Rad - lon1;

    final a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) *
            math.cos(lat2Rad) *
            math.sin(deltaLon / 2) *
            math.sin(deltaLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c; // in metres
  }

  void _highlightCurrentStop() {
    if (_currentBusLocation == null || widget.stopsData.isEmpty) {
      return;
    }

    double minDistance = double.infinity;
    int? closestIndex;

    for (int i = 0; i < widget.stopsData.length; i++) {
      final stop = widget.stopsData[i];
      final stopLat = stop['latitude'] as num?;
      final stopLng = stop['longitude'] as num?;

      if (stopLat != null && stopLng != null) {
        final distance = _calculateDistance(
          _currentBusLocation!,
          stopLat.toDouble(),
          stopLng.toDouble(),
        );

        if (distance < minDistance) {
          minDistance = distance;
          closestIndex = i;
        }
      }
    }

    // Highlight if the closest stop is within the threshold
    if (closestIndex != null && minDistance <= _proximityThreshold) {
      if (_highlightedIndex != closestIndex) {
        setState(() {
          _highlightedIndex = closestIndex;
          // Scroll to the highlighted item
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_highlightedIndex != null &&
                _highlightedIndex! < widget.stopsData.length) {
              _scrollController.animateTo(
                _highlightedIndex! * 56.0, // Approximate height of a ListTile
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          });
        });
      }
    } else {
      if (_highlightedIndex != null) {
        setState(() {
          _highlightedIndex = null; // Clear highlighting if not near a stop
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child:
              widget.stopsData.isEmpty
                  ? const Center(child: Text('No stops data available.'))
                  : ListView.builder(
                    controller:
                        _scrollController, // Attach the ScrollController
                    itemCount: widget.stopsData.length,
                    itemBuilder: (context, index) {
                      final stop = widget.stopsData[index];
                      final stopName =
                          stop['stopName']?.toString().capitalize() ?? 'Stop';
                      final stopTime =
                          stop['stopTime']?.toString() ?? 'Time not available';
                      final isHighlighted = index == _highlightedIndex;

                      return ListTile(
                        key: ValueKey(index), // Add a key for proper scrolling
                        tileColor:
                            isHighlighted ? Colors.yellow.shade100 : null,
                        leading: Icon(
                          isHighlighted
                              ? Icons.location_on
                              : Icons.directions_bus,
                        ),
                        title: Text(
                          stopName,
                          style: TextStyle(
                            fontWeight:
                                isHighlighted
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text('Time: $stopTime'),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
