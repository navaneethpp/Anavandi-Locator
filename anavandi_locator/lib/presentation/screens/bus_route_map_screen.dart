import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anavandi_locator/presentation/widgets/open_street_map_widget.dart';
import 'package:anavandi_locator/data/models/bus_model.dart';
import 'package:anavandi_locator/presentation/widgets/center_bus_button.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

class BusRouteMapScreen extends StatefulWidget {
  final String busRegistrationNumber;
  final String tripId;

  const BusRouteMapScreen({
    super.key,
    required this.busRegistrationNumber,
    required this.tripId,
  });

  @override
  State<BusRouteMapScreen> createState() => _BusRouteMapScreenState();
}

class _BusRouteMapScreenState extends State<BusRouteMapScreen> {
  Bus? _bus;
  final MapController _mapController = MapController();
  List<Marker> _stopMarkers = [];
  Timer? _locationUpdateTimer;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    try {
      await _fetchBusLocation();
      if (_bus?.tripId != null) {
        await _fetchBusStops();
      } else {
        print('Warning: tripId is null, cannot fetch bus stops');
        if (mounted) {
          setState(() {
            _errorMessage = 'Could not find trip information for this bus';
          });
        }
      }
    } catch (e) {
      print('Error initializing data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load bus data';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _startLocationUpdates();
    }
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _startLocationUpdates() {
    _locationUpdateTimer?.cancel(); // Cancel any existing timer
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_bus?.location != null) {
        _fetchBusLocation(updateMap: true);
      }
    });
  }

  Future<void> _fetchBusLocation({bool updateMap = false}) async {
    try {
      print('Fetching location for bus: ${widget.busRegistrationNumber}');

      final busDataSnapshot =
          await FirebaseFirestore.instance
              .collection('busData')
              .where(
                'busRegistrationNumber',
                isEqualTo: widget.busRegistrationNumber.trim(),
              )
              .limit(1)
              .get();

      if (busDataSnapshot.docs.isEmpty) {
        print('Bus not found in busData collection');
        return;
      }

      final bus = Bus.fromFirestore(busDataSnapshot.docs.first);

      // Only fetch tripId if we don't have it yet
      if (_bus?.tripId == null && bus.tripId == null) {
        final assignDataSnapshot =
            await FirebaseFirestore.instance
                .collection('assignData')
                .where(
                  'busRegistrationNumber',
                  isEqualTo: widget.busRegistrationNumber.trim(),
                )
                .limit(1)
                .get();

        if (assignDataSnapshot.docs.isNotEmpty) {
          final tripId =
              assignDataSnapshot.docs.first.data()['tripId'] as String?;
          if (tripId != null) {
            bus.tripId = tripId;
            print('Found tripId: $tripId');
          }
        }
      }

      if (mounted) {
        setState(() {
          _bus = bus;
          if (bus.location != null && updateMap) {
            _mapController.move(
              bus.location!,
              _mapController.camera.zoom,
            ); // Move to the location, keeping the current zoom
          }
        });
      }
    } catch (e) {
      print('Error fetching bus location: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to update bus location';
        });
      }
    }
  }

  Future<void> _fetchBusStops() async {
    try {
      if (_bus?.tripId == null) {
        print('Cannot fetch stops - tripId is null');
        return;
      }

      print('Fetching stops for trip: ${_bus!.tripId}');
      final assignDataSnapshot =
          await FirebaseFirestore.instance
              .collection('assignData')
              .where('tripId', isEqualTo: _bus!.tripId!.trim())
              .limit(1)
              .get();

      if (assignDataSnapshot.docs.isEmpty) {
        print('No assignData found for tripId: ${_bus!.tripId}');
        return;
      }

      final assignData = assignDataSnapshot.docs.first.data();
      if (assignData['busStops'] == null || assignData['busStops'] is! List) {
        print('busStops is null or not a List');
        return;
      }

      final List<Marker> markers = [];
      final busStopsList = assignData['busStops'] as List;

      for (var stopData in busStopsList) {
        try {
          if (stopData is! Map<String, dynamic>) continue;

          final lat = stopData['latitude'];
          final lng = stopData['longitude'];

          if (lat is num && lng is num) {
            markers.add(
              Marker(
                point: LatLng(lat.toDouble(), lng.toDouble()),
                width: 20,
                height: 20,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            );
          }
        } catch (e) {
          print('Error processing stop data: $e');
        }
      }

      if (mounted) {
        setState(() {
          _stopMarkers = markers;
        });
      }
      print('Successfully loaded ${markers.length} bus stops');
    } catch (e) {
      print('Error fetching bus stops: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load bus stops';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Route for ${widget.busRegistrationNumber}')),
      body: Stack(
        children: [
          OpenStreetMapWidget(
            mapController: _mapController,
            initialCenter: _bus?.location,
            initialZoom: 16,
            layers: [
              if (_bus?.location != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _bus!.location!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.directions_bus,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              MarkerLayer(markers: _stopMarkers),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (_bus?.location != null)
            Positioned(
              bottom: 20,
              right: 20,
              child: CenterBusButton(
                mapController: _mapController,
                busLocation: _bus?.location,
              ),
            ),
        ],
      ),
      floatingActionButton:
          _errorMessage != null
              ? FloatingActionButton(
                onPressed: _initializeData,
                child: const Icon(Icons.refresh),
              )
              : null,
    );
  }
}
