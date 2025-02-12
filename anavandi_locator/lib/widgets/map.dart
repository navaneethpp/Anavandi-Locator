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

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates(this.latitude, this.longitude);
}

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTravelStatusDialog(
          context); // Show dialog on app start after frame is built
    });
    _listenToBusLocation();
    _fetchRoute();
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
    FirebaseFirestore.instance
        .collection('location')
        .doc('location')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data.containsKey('Location')) {
          final locationString = data['Location'];

          final coordinates = _extractCoordinates(locationString);
          if (coordinates != null) {
            setState(() {
              _busCurrentLocation =
                  LatLng(coordinates.latitude, coordinates.longitude);
              if (_busCurrentLocation != null) {
                // Center map on bus location update
                _mapController.move(_busCurrentLocation!, zoomValue);
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

  Future<void> _fetchRoute() async {
    const String apiKey =
        openRouteSerivceAPI; // API key for oper route services
    const String apiUrl =
        'https://api.openrouteservice.org/v2/directions/driving-car';
    const LatLng startPoint = LatLng(10.765701711281343, 75.92560325817277);
    const LatLng endPoint = LatLng(10.767729909389303, 76.6493706289483);

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
    if (_busCurrentLocation != null) {
      _mapController.move(_busCurrentLocation!, zoomValue);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bus location is not available.')),
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
    return const Marker(
      point: LatLng(10.767571520930707, 76.64942283322327),
      width: 40,
      height: 40,
      child: (Icon(
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
