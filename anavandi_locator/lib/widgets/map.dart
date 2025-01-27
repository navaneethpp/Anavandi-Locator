// map.dart

import 'package:anavandi_locator/api/open_route_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'constants.dart'; // Import the constants file
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _mapController = MapController();
  LatLng? _userLocation; // Make nullable
  final LatLng _busCurrentLocation =
      const LatLng(10.767529113068605, 76.64929215373253);
  final LatLng _busEndLocation =
      const LatLng(10.765584666481779, 75.92557352614128);
  List<LatLng> _routePoints = [];
  bool _loadingLocation = false;
  final String _openRouteServiceApiKey =
      openRouteSerivceAPI; // Replace with your API key

  @override
  void initState() {
    super.initState();
    _initializeUserLocation();
    _fetchDirections();
  }

  Future<void> _initializeUserLocation() async {
    setState(() {
      _loadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        bool shouldOpenSettings = await _showEnableGpsDialog();
        if (shouldOpenSettings) {
          await Geolocator.openLocationSettings();
        }
        throw Exception('Location services are disabled.');
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await Geolocator.requestPermission();
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      LatLng currentLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _userLocation = currentLocation;
      });

      // Move map to the user's location
      _mapController.move(currentLocation, 14);
    } catch (e) {
      setState(() {
        _userLocation = null; // Set to null if location is unavailable
      });
      _mapController.move(_busCurrentLocation, 14); // Center on bus
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _loadingLocation = false;
      });
    }
  }

  Future<bool> _showEnableGpsDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Enable GPS'),
            content: const Text(
                'Location services are disabled. Would you like to enable GPS?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Enable'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _fetchDirections() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.openrouteservice.org/v2/directions/driving-car?start=${_busCurrentLocation.longitude},${_busCurrentLocation.latitude}&end=${_busEndLocation.longitude},${_busEndLocation.latitude}'),
        headers: {'Authorization': _openRouteServiceApiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> coordinates =
            data['features'][0]['geometry']['coordinates'];

        setState(() {
          _routePoints = coordinates
              .map((coord) => LatLng(coord[1], coord[0])) // Convert to LatLng
              .toList();
        });
      } else {
        throw Exception('Failed to fetch directions: ${response.reasonPhrase}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching directions: ${e.toString()}')),
      );
    }
  }

  void _recenterMap(LatLng targetLocation) {
    _mapController.move(targetLocation, 14);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _busCurrentLocation, // Default to bus location
              initialZoom: 11,
            ),
            children: [
              openStreetMapTileLayer,
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // User location (only if available)
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: iconSize,
                      height: iconSize,
                      alignment: Alignment.center,
                      child: const Icon(
                        FontAwesomeIcons.locationDot,
                        size: iconSize, // Use the constant here
                        color: Colors.blue,
                      ),
                    ),

                  // Bus current Location
                  Marker(
                    point: _busCurrentLocation,
                    width: iconSize,
                    height: iconSize,
                    alignment: Alignment.center,
                    child: Icon(
                      FontAwesomeIcons.busSimple,
                      size: iconSize, // Use the constant here
                      color: Colors.green[700],
                    ),
                  ),

                  // Bus End Location
                  Marker(
                    point: _busEndLocation,
                    width: iconSize,
                    height: iconSize,
                    alignment: Alignment.center,
                    child: const Icon(
                      FontAwesomeIcons
                          .flagCheckered, // Changed to flag for end location
                      size: iconSize, // Use the constant here
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_loadingLocation)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            bottom: 20,
            left: 10,
            child: Container(
              color: Colors.white.withOpacity(0.7),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: const Text(
                'OpenStreetMap Contributors',
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'user' && _userLocation != null) {
            _recenterMap(_userLocation!);
          } else if (value == 'bus') {
            _recenterMap(_busCurrentLocation);
          } else if (value == 'fetchLocation') {
            _initializeUserLocation(); // Fetch current location
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'user',
            child: Text('Re-center on User'),
          ),
          const PopupMenuItem(
            value: 'bus',
            child: Text('Re-center on Bus'),
          ),
          const PopupMenuItem(
            value: 'fetchLocation',
            child: Text('Fetch Current Location'),
          ),
        ],
        child: const FloatingActionButton(
          onPressed: null,
          child: Icon(Icons.menu),
        ),
      ),
    );
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
    );
