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
  final double _proximityThreshold =
      50; // Proximity in meters for "Currently here"
  final double _arrivingThreshold = 200; // Proximity in meters for "Arriving"
  final ScrollController _scrollController = ScrollController();
  Map<int, String> _stopStatuses = {};

  @override
  void initState() {
    super.initState();
    _currentBusLocation = widget.initialBusLocation;
    widget.busLocationStream.listen((location) {
      if (mounted && location != null) {
        setState(() {
          _currentBusLocation = location;
          _updateStopStatuses();
        });
      }
    });
    _updateStopStatuses();
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

  void _updateStopStatuses() {
    if (_currentBusLocation == null || widget.stopsData.isEmpty) {
      setState(() {
        _highlightedIndex = null;
        _stopStatuses.clear();
      });
      return;
    }

    int? closestIndex;
    double minDistance = double.infinity;

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

    setState(() {
      _stopStatuses.clear();
      _highlightedIndex = closestIndex;

      if (closestIndex != null) {
        if (minDistance <= _proximityThreshold) {
          _stopStatuses[closestIndex] = "Currently here";
          for (int i = 0; i < closestIndex; i++) {
            _stopStatuses[i] = "Departed";
          }
          if (closestIndex < widget.stopsData.length - 1) {
            final nextStop = widget.stopsData[closestIndex + 1];
            final nextStopLat = nextStop['latitude'] as num?;
            final nextStopLng = nextStop['longitude'] as num?;
            if (nextStopLat != null && nextStopLng != null) {
              final distanceToNext = _calculateDistance(
                _currentBusLocation!,
                nextStopLat.toDouble(),
                nextStopLng.toDouble(),
              );
              if (distanceToNext <= _arrivingThreshold) {
                _stopStatuses[closestIndex + 1] = "Arriving";
              } else {
                // Mark the next stop if not arriving yet
                if (closestIndex + 1 < widget.stopsData.length) {
                  _stopStatuses[closestIndex + 1] = "Next";
                }
              }
            } else {
              // Mark the next stop if not arriving yet (in case of null coordinates)
              if (closestIndex + 1 < widget.stopsData.length) {
                _stopStatuses[closestIndex + 1] = "Next";
              }
            }
          }
        } else {
          // If not close to any stop, mark previous as departed and next as arriving if close
          for (int i = 0; i < widget.stopsData.length; i++) {
            if (closestIndex != null && i < closestIndex) {
              _stopStatuses[i] = "Departed";
            } else if (closestIndex != null && i == closestIndex) {
              // Could indicate just departed
            } else if (closestIndex != null && i == closestIndex + 1) {
              final stop = widget.stopsData[i];
              final stopLat = stop['latitude'] as num?;
              final stopLng = stop['longitude'] as num?;
              if (stopLat != null && stopLng != null) {
                final distanceToNext = _calculateDistance(
                  _currentBusLocation!,
                  stopLat.toDouble(),
                  stopLng.toDouble(),
                );
                if (distanceToNext <= _arrivingThreshold) {
                  _stopStatuses[i] = "Arriving";
                } else {
                  _stopStatuses[i] = "Next";
                }
              } else {
                _stopStatuses[i] = "Next";
              }
            }
          }
        }

        // Scroll to the highlighted item
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_highlightedIndex != null &&
              _highlightedIndex! < widget.stopsData.length) {
            _scrollController.animateTo(
              _highlightedIndex! * 70.0, // Adjust for the layout
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
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
                    controller: _scrollController,
                    itemCount: widget.stopsData.length,
                    itemBuilder: (context, index) {
                      final stop = widget.stopsData[index];
                      final stopName =
                          stop['stopName']?.toString().capitalize() ?? 'Stop';
                      final stopTime =
                          stop['stopTime']?.toString() ?? 'Time not available';
                      final nearCity = stop['nearestTown']?.toString() ?? '';
                      final isHighlighted =
                          index == _highlightedIndex &&
                          _stopStatuses[index] == "Currently here";
                      final isFirst = index == 0;
                      final isLast = index == widget.stopsData.length - 1;
                      final statusText = _stopStatuses[index];
                      final isNextStop = _stopStatuses[index] == "Next";

                      return Padding(
                        key: ValueKey(index),
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timeline Indicator
                            SizedBox(
                              width: 40,
                              height: 60,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Vertical Line
                                  if (!isFirst)
                                    Positioned(
                                      top: 0,
                                      bottom: 30,
                                      child: Container(
                                        width: 2,
                                        height: double.infinity,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  if (!isLast)
                                    Positioned(
                                      top: 30,
                                      bottom: 0,
                                      child: Container(
                                        width: 2,
                                        height: double.infinity,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  // Stop Indicator
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          isHighlighted
                                              ? Colors.blue
                                              : isNextStop
                                              ? Colors
                                                  .orange // Example color for "Next"
                                              : Colors.grey.shade400,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child:
                                        isHighlighted
                                            ? const Icon(
                                              Icons.location_on,
                                              color: Colors.white,
                                              size: 14,
                                            )
                                            : isNextStop
                                            ? const Icon(
                                              Icons
                                                  .flag, // Example icon for "Next"
                                              color: Colors.white,
                                              size: 14,
                                            )
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Stop Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stopName,
                                    style: TextStyle(
                                      fontWeight:
                                          isHighlighted || isNextStop
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (nearCity.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Text(
                                        nearCity,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'Time: $stopTime',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      if (statusText != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                          ),
                                          child: Text(
                                            statusText,
                                            style: TextStyle(
                                              color:
                                                  statusText == "Currently here"
                                                      ? Colors.blue
                                                      : statusText == "Arriving"
                                                      ? Colors.green
                                                      : isNextStop
                                                      ? Colors.orange
                                                      : Colors.grey.shade600,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
