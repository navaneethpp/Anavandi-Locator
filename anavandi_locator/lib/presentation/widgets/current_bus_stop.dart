import 'package:anavandi_locator/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

class CurrentBusStop extends StatefulWidget {
  final Stream<LatLng?> busLocationStream;
  final List<Map<String, dynamic>> stopsData;

  const CurrentBusStop({
    super.key,
    required this.busLocationStream,
    required this.stopsData,
  });

  @override
  State<CurrentBusStop> createState() => _CurrentBusStopState();
}

class _CurrentBusStopState extends State<CurrentBusStop> {
  LatLng? _currentBusLocation;
  String? _currentStopName;
  final double _proximityThreshold = 50; // Proximity in meters

  @override
  void initState() {
    super.initState();
    widget.busLocationStream.listen((location) {
      if (mounted && location != null) {
        setState(() {
          _currentBusLocation = location;
          _findCurrentStop();
        });
      }
    });
    // Initial check in case the stream emits immediately
    _findCurrentStop();
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

  void _findCurrentStop() {
    if (_currentBusLocation == null || widget.stopsData.isEmpty) {
      setState(() {
        _currentStopName = null;
      });
      return;
    }

    double minDistance = double.infinity;
    String? closestStopName;

    for (final stop in widget.stopsData) {
      final stopLat = (stop['latitude'] as num?)?.toDouble();
      final stopLng = (stop['longitude'] as num?)?.toDouble();
      final stopName = stop['stopName']?.toString();

      if (stopLat != null && stopLng != null && stopName != null) {
        final distance = _calculateDistance(
          _currentBusLocation!,
          stopLat,
          stopLng,
        );

        if (distance < minDistance) {
          minDistance = distance;
          closestStopName = stopName;
        }
      }
    }

    if (closestStopName != null && minDistance <= _proximityThreshold) {
      setState(() {
        _currentStopName = closestStopName;
      });
    } else {
      setState(() {
        _currentStopName = null; // Or a default message like "Not near a stop"
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentStopName != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Stop',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4.0),
                Text(_currentStopName?.capitalize() ?? 'Not Available'),
                const Divider(),
              ],
            ),
          ),
        if (_currentStopName == null && _currentBusLocation != null)
          const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Locating current stop...',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        if (_currentBusLocation == null)
          const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Bus location not available.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }
}
