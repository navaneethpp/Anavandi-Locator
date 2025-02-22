// map.dart
// This widget displays a FlutterMap view to show bus location, user location, and route polyline.
// It integrates with Firebase Firestore to get real-time bus location updates and
// uses OpenRouteService API to fetch route polyline between user and bus destination.
// Includes features like centering map on bus or user location, refetching user location,
// and a compass widget for orientation.

// Documentation:
//
// Widget Purpose:
// The MapWidget is a StatefulWidget designed to display an interactive map interface using FlutterMap.
// It provides real-time tracking of bus location, displays user's current location (optional, based on user travel status),
// and visualizes the route polyline from the user's starting point to the bus's destination.
// The widget is intended to give users a clear visual representation of the bus's current position
// in relation to their own location and the intended route.
//
// Key Features:
// - Real-time Bus Location Tracking: Listens to location updates from Firebase Firestore and updates the bus marker on the map dynamically.
// - User Location Display:  Optionally displays the user's current location on the map. Location fetching is initiated based on user's travel status (in or out of bus).
// - Route Polyline Visualization: Fetches driving route polyline using OpenRouteService API and renders it on the map, showing the path from user's assumed starting point to the bus destination.
// - Map Controls: Provides a menu (using a FloatingActionButton and BottomSheet) with options to:
//     - Center the map on the current bus location.
//     - Center the map on the user's location (conditionally available).
//     - Re-fetch user's location (conditionally available).
// - Compass Integration: Includes a CompassWidget (from compass_widget.dart) to provide directional orientation on the map.
// - Location Permission Handling: Manages location permissions using `geolocator` package, requesting permissions if needed and handling denied/permanently denied scenarios.
// - User Travel Status Dialog: On widget initialization, presents a dialog to the user asking if they are traveling in the bus.
//   This status affects user location fetching behavior (periodic fetching when not in bus, stopped fetching when in bus).
// - Error Handling: Includes basic error handling for location service issues, permission denials, API call failures, and invalid data formats, displaying SnackBar messages for user feedback.
//
// Working:
// - Initialization (`initState`):
//     - Shows a "Travelling in Bus?" dialog to determine user's travel status using `_showTravelStatusDialog`.
//     - Starts listening for bus location updates from Firestore using `_listenToBusLocation`.
//     - Fetches the route polyline from user's assumed starting location to the bus destination using `_fetchRoute`.
// - User Location Management:
//     - `_initializeUserLocation`: Fetches the user's current location using `geolocator`.
//       This function handles location service availability, permission checks, and updates the `_userLocation` state variable.
//       Map is moved to center on user location upon successful fetch.
//     - Location fetching can be triggered manually from the menu or automatically based on user's travel status and a periodic timer (`_locationFetchTimer`).
//     - Periodic location fetching starts if user indicates they are NOT in the bus and is stopped if they indicate they ARE in the bus.
// - Bus Location Tracking (`_listenToBusLocation`):
//     - Sets up a Firestore snapshot listener on 'location/location' document to receive real-time bus location updates.
//     - Extracts latitude and longitude coordinates from the 'Location' field in Firestore data using `_extractCoordinates`.
//     - Updates the `_busCurrentLocation` state variable and moves the map to center on the bus location whenever a valid update is received.
// - Route Polyline Fetching (`_fetchRoute`):
//     - Uses OpenRouteService API to fetch driving directions between user's starting coordinates (passed as widget parameters) and bus destination coordinates (passed as widget parameters).
//     - Parses the API response to extract route coordinates and updates the `_polylinePoints` state variable, triggering polyline rendering on the map.
// - Map Building (`_buildMap`):
//     - Uses `FutureBuilder` to handle asynchronous initial location loading (either bus or user location for initial map center).
//     - Creates a `FlutterMap` widget with:
//         - `TileLayer` for displaying OpenStreetMap tiles.
//         - `MarkerLayer` to display markers for bus location, user location (conditional), and bus destination.
//         - `PolylineLayer` (conditional) to render the route polyline if `_polylinePoints` is populated.
//         - `MapController` (`_mapController`) to programmatically control the map (move, zoom).
// - Map Controls Menu (`_showMenu`, `_centerMapOnBusLocation`, `_centerMapOnUserLocation`):
//     - Provides a bottom sheet menu with options to center the map on bus location, user location, and refetch user location.
//     - These functions use `_mapController.move` to reposition the map view.
// - Markers (`_buildMarkers`, `_createBusMarker`, `_createUserMarker`, `_busEndMark`):
//     - Creates `Marker` widgets for bus, user, and bus destination locations, using Icons and setting marker points, sizes, and colors.
// - Utility Functions:
//     - `_extractCoordinates`: Parses a location string (latitude, longitude format) into a `Coordinates` object.
//     - `_getUserOrBusLocation`: Determines the initial map center based on availability of bus or user location.
//
// UI Elements:
// - Scaffold: Provides basic page structure.
// - Stack: Used for layering map, loading indicator, compass, and watermark.
// - FlutterMap: The core map widget from flutter_map package.
// - TileLayer: Displays map tiles.
// - MarkerLayer: Renders markers on the map.
// - PolylineLayer: Renders route polyline on the map.
// - FloatingActionButton: Opens the map controls menu.
// - BottomSheet: Displays map control options.
// - CircularProgressIndicator: Shows loading indication while fetching user location.
// - CompassWidget: (Imported from compass_widget.dart) Displays compass orientation.
// - Text (Watermark): Displays OpenStreetMap attribution.
// - AlertDialog: "Travelling in Bus?" dialog.
// - SnackBar: Displays error messages to the user.
//
// State Variables:
// - `_mapController`: `MapController` instance to control the FlutterMap.
// - `_userLocation`: `LatLng?` for user's current location.
// - `_busCurrentLocation`: `LatLng?` for bus's current location.
// - `_loadingLocation`: `bool` to track if user location is being fetched.
// - `_polylinePoints`: `List<LatLng>` to store route polyline coordinates.
// - `_isTravellingInBus`: `bool?` to store user's travel status (null initially, true/false after dialog).
// - `_locationFetchTimer`: `Timer?` to manage periodic user location fetching.
// - `_mapReady`: `bool` to track if the FlutterMap widget is ready.  **[NEW: for error fix]**
//
// Dependencies:
// - flutter_map: For map display and interaction.
// - latlong2: For LatLng coordinate class.
// - geolocator: For fetching device location.
// - font_awesome_flutter: For FontAwesome icons.
// - http: For making HTTP requests to OpenRouteService API.
// - cloud_firestore: For accessing bus location data from Firebase Firestore.
// - compass_widget.dart: For the CompassWidget implementation.
// - constants.dart: For map-related constants (iconSize, zoomValue).
// - open_route_service.dart: (Assumed) For API key constant for OpenRouteService.

import 'dart:async';
import 'dart:convert';
import 'package:anavandi_locator/api/open_route_service.dart';
import 'package:anavandi_locator/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'compass_widget.dart'; // Import the CompassWidget

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates(this.latitude, this.longitude);
}

class MapWidget extends StatefulWidget {
  final double endLatitude;
  final double endLongitude;
  final double userStartLatitude; // Add this
  final double userStartLongitude; // Add this

  const MapWidget({
    Key? key,
    required this.endLatitude,
    required this.endLongitude,
    required this.userStartLatitude, // Add this to constructor
    required this.userStartLongitude, // Add this to constructor
  }) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  LatLng? _busCurrentLocation;
  bool _loadingLocation = false;
  List<LatLng> _polylinePoints = [];
  bool? _isTravellingInBus; // Added state variable
  Timer? _locationFetchTimer; // Timer for periodic location fetching
  bool _mapReady = false; // **[NEW] Flag to track map readiness**

  @override
  void initState() {
    super.initState();
    print("MapWidgetState - initState"); // **[DEBUG]**
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTravelStatusDialog(
          context); // Show dialog on app start after frame is built
    });
    _listenToBusLocation();
    _fetchRoute(
      widget.endLatitude,
      widget.endLongitude,
      widget.userStartLatitude, // Pass user start latitude
      widget.userStartLongitude, // Pass user start longitude
    );
  }

  @override
  void dispose() {
    _locationFetchTimer?.cancel(); // Cancel timer if active
    super.dispose();
  }

  void _startLocationFetching() {
    if (_locationFetchTimer == null || !_locationFetchTimer!.isActive) {
      _locationFetchTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        if (_isTravellingInBus == false) {
          _initializeUserLocation();
        } else {
          _locationFetchTimer
              ?.cancel(); // Stop timer if user selects "Yes" later
        }
      });
    }
  }

  void _stopLocationFetching() {
    _locationFetchTimer?.cancel();
  }

  Future<void> _showTravelStatusDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Travelling in Bus?'),
          content: const Text('Are you still travelling in the bus?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                setState(() {
                  _isTravellingInBus = false;
                });
                _initializeUserLocation(); // Fetch location immediately on 'No'
                _startLocationFetching(); // Start periodic fetching
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                setState(() {
                  _isTravellingInBus = true;
                });
                _stopLocationFetching(); // Stop periodic fetching if it was started before
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _initializeUserLocation() async {
    if (_isTravellingInBus == true) {
      return; // Do not fetch location if user is in bus and answered "Yes"
    }
    setState(() {
      _loadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Location permission permanently denied.')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      LatLng currentLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _userLocation = currentLocation;
      });

      _mapController.move(currentLocation, zoomValue);
      print("User Location: $_userLocation");
    } catch (e) {
      _mapController.move(LatLng(10.767529, 76.649292), zoomValue);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _loadingLocation = false;
      });
    }
  }

  void _listenToBusLocation() {
    print("_listenToBusLocation - start listening"); // **[DEBUG]**
    FirebaseFirestore.instance
        .collection('location')
        .doc('location')
        .snapshots()
        .listen((snapshot) {
      print("_listenToBusLocation - snapshot received"); // **[DEBUG]**
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data.containsKey('Location')) {
          final locationString = data['Location'];

          final coordinates = _extractCoordinates(locationString);
          if (coordinates != null) {
            setState(() {
              _busCurrentLocation =
                  LatLng(coordinates.latitude, coordinates.longitude);
              if (_busCurrentLocation != null && _mapReady) {
                // **[FIX] Check if map is ready**
                print(
                    "_listenToBusLocation - moving map to bus location"); // **[DEBUG]**
                _mapController.move(_busCurrentLocation!, zoomValue);
              } else {
                print(
                    "_listenToBusLocation - map not ready, or bus location null"); // **[DEBUG]**
              }
            });
          } else {
            print(
                "Invalid location string format in Firestore: $locationString");
          }
        } else {
          print("Document or 'Location' field doesn't exist");
        }
      } else {
        print("Snapshot doesn't exist");
      }
    });
  }

  Coordinates? _extractCoordinates(String locationString) {
    try {
      final parts = locationString.split(RegExp(r',\s*'));
      if (parts.length != 2) return null;

      final latitudeString = parts[0].replaceAll(RegExp(r'[\u00B0N]'), '');
      final longitudeString = parts[1].replaceAll(RegExp(r'[\u00B0E]'), '');

      final latitude = double.parse(latitudeString);
      final longitude = double.parse(longitudeString);

      return Coordinates(latitude, longitude);
    } catch (e) {
      print("Error parsing coordinates: $e, String: $locationString");
      return null;
    }
  }

  Future<void> _fetchRoute(double endLatitude, double endLongitude,
      double userStartLatitude, double userStartLongitude) async {
    // Accept user start lat and long
    const String apiKey = openRouteSerivceAPI;
    const String apiUrl =
        'https://api.openrouteservice.org/v2/directions/driving-car';
    final LatLng startPoint = LatLng(
        userStartLatitude, userStartLongitude); // Use user start lat and long
    final LatLng endPoint = LatLng(endLatitude, endLongitude);

    final url = Uri.parse(
        '$apiUrl?api_key=$apiKey&start=${startPoint.longitude},${startPoint.latitude}&end=${endPoint.longitude},${endPoint.latitude}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> coordinates =
            data['features'][0]['geometry']['coordinates'];

        setState(() {
          _polylinePoints =
              coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
        });
      } else {
        print('Failed to fetch route: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          if (_loadingLocation)
            const Center(child: CircularProgressIndicator()),

          // Compass Widget added here, in top-right corner
          const Positioned(
            bottom: 16.0,
            left: 16.0,
            child: CompassWidget(),
          ),

          // Below section is to display the water mark above the map.
          const Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '© OpenStreetMap Contributors',
                style: TextStyle(
                  fontSize: 15,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMenu(context),
        child: const Icon(Icons.menu),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(FontAwesomeIcons.busSimple),
              title: const Text('Center Bus Location'),
              onTap: () {
                Navigator.pop(context);
                _centerMapOnBusLocation();
              },
            ),
            if (_isTravellingInBus == false ||
                _isTravellingInBus ==
                    null) // Conditionally display Center User Location
              ListTile(
                leading: const Icon(Icons.person_pin),
                title: const Text('Center User Location'),
                onTap: () {
                  Navigator.pop(context);
                  _centerMapOnUserLocation();
                },
              ),
            if (_isTravellingInBus == false ||
                _isTravellingInBus ==
                    null) // Conditionally display Re-fetch User Location
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Re-fetch User Location'),
                onTap: () {
                  Navigator.pop(context);
                  _initializeUserLocation();
                },
              ),
          ],
        );
      },
    );
  }

  void _centerMapOnUserLocation() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, zoomValue);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User location is not available.')),
      );
    }
  }

  void _centerMapOnBusLocation() {
    if (_busCurrentLocation != null && _mapReady) {
      // **[FIX] Check if map is ready**
      _mapController.move(_busCurrentLocation!, zoomValue);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bus location is not available or map not ready.')),
      );
    }
  }

  FutureBuilder<LatLng?> _buildMap() {
    return FutureBuilder<LatLng?>(
      future: _getUserOrBusLocation(),
      builder: (context, snapshot) {
        LatLng initialCenter = snapshot.data ?? LatLng(10.767529, 76.649292);
        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: zoomValue,
            onMapReady: () {
              // **[FIX] onMapReady callback**
              setState(() {
                _mapReady =
                    true; // **[FIX] Set mapReady to true when map is ready**
              });
              print(
                  "FlutterMap - onMapReady callback triggered"); // **[DEBUG]**
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'dev.fleaflet.flutter_map.example',
            ),
            _buildMarkers(),
            if (_polylinePoints.isNotEmpty) _buildPolyline(),
          ],
        );
      },
    );
  }

  Widget _buildPolyline() {
    return PolylineLayer(
      polylines: [
        Polyline(
          points: _polylinePoints,
          color: Colors.blue,
          strokeWidth: 4.0,
        ),
      ],
    );
  }

  Widget _buildMarkers() {
    List<Marker> markers = [];
    if (_busCurrentLocation != null) {
      markers.add(_createBusMarker());
    }
    if (_userLocation != null &&
        (_isTravellingInBus == false || _isTravellingInBus == null)) {
      // Conditionally display user marker
      markers.add(_createUserMarker());
    }
    markers.add(_busEndMark());
    return MarkerLayer(markers: markers);
  }

  Marker _createBusMarker() {
    return Marker(
      point: _busCurrentLocation!,
      width: 40,
      height: 40,
      child: const Icon(
        Icons.directions_bus,
        color: Colors.redAccent,
        size: iconSize,
      ),
    );
  }

  Marker _createUserMarker() {
    return Marker(
      point: _userLocation!,
      width: 40,
      height: 40,
      child: const Icon(
        Icons.person_pin_circle,
        color: Colors.blue,
        size: iconSize,
      ),
    );
  }

  Marker _busEndMark() {
    return Marker(
      point: LatLng(widget.endLatitude, widget.endLongitude),
      width: 40,
      height: 40,
      child: (const Icon(
        Icons.flag,
        color: Colors.green,
        size: iconSize,
      )),
    );
  }

  Future<LatLng?> _getUserOrBusLocation() async {
    if (_busCurrentLocation != null) {
      return _busCurrentLocation;
    } else if (_userLocation != null &&
        (_isTravellingInBus == false || _isTravellingInBus == null)) {
      return _userLocation;
    }
    return null;
  }
}
