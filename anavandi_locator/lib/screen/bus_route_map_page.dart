import 'package:anavandi_locator/api/open_route_service.dart';
import 'package:anavandi_locator/widgets/center_on_bus_button.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anavandi_locator/screen/more_info_screen.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator package
import 'package:anavandi_locator/functions/eta_calculator.dart';

class BusRouteMapPage extends StatefulWidget {
  final String startingPointName;
  final String endingPointName;
  final String busRegistrationNumber;
  final DocumentSnapshot assignDataDocument;
  final DocumentSnapshot busDataDocument;

  const BusRouteMapPage({
    super.key,
    required this.startingPointName,
    required this.endingPointName,
    required this.busRegistrationNumber,
    required this.assignDataDocument,
    required this.busDataDocument,
  });

  @override
  State<BusRouteMapPage> createState() => _BusRouteMapPageState();
}

class _BusRouteMapPageState extends State<BusRouteMapPage>
    with SingleTickerProviderStateMixin {
  LatLng? _startLocation;
  LatLng? _endLocation;
  List<LatLng> _polylinePoints = [];
  LatLng? _busLocation;
  LatLng? _userLocation; // User location fetched in this page
  bool _isInBus = false; // Track if the user is in the bus
  String _eta = ''; // Estimated Time of Arrival

  // Add a map controller to programmatically control the map
  final MapController _mapController = MapController();

  // Add a StreamSubscription to manage the Firestore listener
  StreamSubscription<QuerySnapshot>? _busLocationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _askIfUserIsInBus(); // Call _askIfUserIsInBus after first frame
    });
  }

  Future<void> _askIfUserIsInBus() async {
    print('BusRouteMapPage: _askIfUserIsInBus started');
    bool? isInBusResult = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Are you in the bus?'),
            content: const Text('Do you want to see your location on the map?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // No, fetch user location
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pop(true); // Yes, don't fetch user location
                },
                child: const Text('Yes'),
              ),
            ],
          ),
    );

    if (isInBusResult != null) {
      setState(() {
        _isInBus = isInBusResult;
      });
      _loadPageData();
    } else {
      // Handle the case where the dialog is dismissed without a selection (e.g., tapping outside)
      // Default to fetching user location (No option) in this case, or handle as needed.
      setState(() {
        _isInBus = false; // Default to 'No' if no explicit choice
      });
      _loadPageData();
    }
    print('BusRouteMapPage: _askIfUserIsInBus finished - _isInBus: $_isInBus');
  }

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _busLocationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadPageData() async {
    print('BusRouteMapPage: _loadPageData started');
    try {
      await _geocodeLocations();
      if (_startLocation != null && _endLocation != null) {
        await _fetchRoutePolyline();
      }
      if (!_isInBus) {
        await _fetchUserLocation(); // Fetch user location only if not in bus
      } else {
        print('BusRouteMapPage: User is in bus, skipping user location fetch.');
      }
      // Replace one-time fetch with stream subscription
      _setupBusLocationListener();
    } catch (e) {
      print(
        'BusRouteMapPage: Error in _loadPageData: $e',
      ); // Catch errors in loadPageData
    }
    print('BusRouteMapPage: _loadPageData finished');
  }

  // Fetch user's current location
  Future<void> _fetchUserLocation() async {
    if (_isInBus) {
      print('BusRouteMapPage: _fetchUserLocation skipped as user is in bus.');
      return;
    }
    print('BusRouteMapPage: _fetchUserLocation started');
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('BusRouteMapPage: Location services are disabled.');
      // Show a SnackBar to inform the user and offer to open settings
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Location services are disabled. Please enable them to show your location on the map.',
            ),
            duration: const Duration(seconds: 5), // Adjust duration as needed
            action: SnackBarAction(
              label: 'Enable Location',
              onPressed: () async {
                await Geolocator.openLocationSettings(); // Open device location settings
              },
            ),
          ),
        );
      }
      return; // Don't proceed fetching location if services are disabled
    }

    // Check location permissions (rest of the function remains the same)
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print(
          'BusRouteMapPage: Location permissions are denied. Cannot fetch user location.',
        );
        return; // Don't proceed if permissions are denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print(
        'BusRouteMapPage: Location permissions are permanently denied. Cannot fetch user location.',
      );
      return; // Don't proceed if permissions are permanently denied
    }

    // Get current location (rest of the function remains the same)
    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
        print('BusRouteMapPage: User location fetched: $_userLocation');
      }
    } catch (e) {
      print('BusRouteMapPage: Error fetching user location: $e');
    }
    print('BusRouteMapPage: _fetchUserLocation finished');
  }

  // Setup real-time listener for bus location
  void _setupBusLocationListener() {
    print('BusRouteMapPage: Setting up real-time bus location listener');
    try {
      final Stream<QuerySnapshot> busDataStream =
          FirebaseFirestore.instance
              .collection('busData')
              .where(
                'busRegistrationNumber',
                isEqualTo: widget.busRegistrationNumber,
              )
              .limit(1)
              .snapshots();

      _busLocationSubscription = busDataStream.listen(
        (QuerySnapshot snapshot) {
          print('BusRouteMapPage: Received bus location update from Firestore');
          if (snapshot.docs.isNotEmpty) {
            DocumentSnapshot busDataDoc = snapshot.docs.first;
            Map<String, dynamic> busLocationData =
                busDataDoc.data() as Map<String, dynamic>;

            List<dynamic>? locationArray =
                busLocationData['location'] as List<dynamic>?;
            if (locationArray != null && locationArray.length == 2) {
              final lat = double.tryParse(locationArray[0].toString());
              final lon = double.tryParse(locationArray[1].toString());
              if (lat != null && lon != null) {
                if (mounted) {
                  setState(() {
                    _busLocation = LatLng(lat, lon);
                  });
                  print('BusRouteMapPage: Bus location updated: $_busLocation');
                  calculateETA(
                    busLocation: _busLocation,
                    userLocation: _userLocation,
                    endLocation: _endLocation,
                    isInBus: _isInBus,
                    onEtaUpdated: (eta) {
                      if (mounted) {
                        setState(() {
                          _eta = eta;
                        });
                      }
                    },
                    mounted: mounted,
                    vsync: this, // Pass the TickerProvider
                    openRouteSerivceAPI: openRouteSerivceAPI,
                  );
                  ; // Calculate ETA whenever bus location updates
                }
                return;
              } else {
                print(
                  'BusRouteMapPage: Parsing error for bus location - lat: $lat, lon: $lon',
                );
              }
            } else {
              print(
                'BusRouteMapPage: Invalid location format for bus ${widget.busRegistrationNumber}: $locationArray',
              );
            }
          } else {
            print('BusRouteMapPage: No bus data found in latest snapshot');
          }

          if (mounted) {
            setState(() {
              // Keep previous location if new one is invalid
            });
          }
        },
        onError: (error) {
          print('BusRouteMapPage: Error in bus location listener: $error');
          if (mounted) {
            setState(() {
              // Keep previous location on error
            });
          }
        },
      );
    } catch (e) {
      print('BusRouteMapPage: Error setting up bus location listener: $e');
    }
  }

  // Add this method to center the map on the bus location
  void _centerOnBus() {
    if (_busLocation != null) {
      print('BusRouteMapPage: Centering map on bus location: $_busLocation');
      _mapController.move(
        _busLocation!,
        15.0,
      ); // Zoom level 15 for better visibility

      // Show a brief confirmation to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Centered on bus location'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      print('BusRouteMapPage: Cannot center on bus - location is null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bus location not available'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _geocodeLocations() async {
    print(
      'BusRouteMapPage: _geocodeLocations - Starting Point Name: ${widget.startingPointName}, Ending Point Name: ${widget.endingPointName}',
    );

    try {
      _startLocation = await _geocodePlaceNameToLatLng(
        widget.startingPointName,
        'start',
      );
      print(
        'BusRouteMapPage: _geocodeLocations - _startLocation after geocoding: $_startLocation',
      );

      _endLocation = await _geocodePlaceNameToLatLng(
        widget.endingPointName,
        'end',
      );
      print(
        'BusRouteMapPage: _geocodeLocations - _endLocation after geocoding: $_endLocation',
      );

      if (_startLocation == null || _endLocation == null) {
        print('BusRouteMapPage: Geocoding failed for start or end point.');
      }
    } catch (e) {
      print(
        'BusRouteMapPage: Error in _geocodeLocations: $e',
      ); // Catch geocode errors
    }

    print(
      'BusRouteMapPage: _geocodeLocations finished - startLocation: $_startLocation, endLocation: $_endLocation',
    );
  }

  Future<LatLng?> _geocodePlaceNameToLatLng(
    String placeName,
    String pointType,
  ) async {
    print(
      'BusRouteMapPage: _geocodePlaceNameToLatLng started for $pointType: $placeName',
    );
    if (placeName.isEmpty) {
      print(
        'BusRouteMapPage: _geocodePlaceNameToLatLng - Place name is empty for $pointType',
      );
      return null;
    }
    final Uri url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$placeName&countrycodes=in&format=json&limit=1',
    );
    print(
      'BusRouteMapPage: Nominatim API URL for geocoding ($pointType): ${url.toString()}',
    );

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'AnavandiLocatorApp'},
      );

      if (response.statusCode == 200) {
        print(
          'BusRouteMapPage: Nominatim API response for $pointType - Status Code: ${response.statusCode}',
        );
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty && data[0] != null) {
          final item = data[0];
          final lat = double.tryParse(item['lat'].toString());
          final lon = double.tryParse(item['lon'].toString());
          if (lat != null && lon != null) {
            print(
              'BusRouteMapPage: Geocoding successful for $pointType - Lat: $lat, Lon: $lon',
            );
            return LatLng(lat, lon);
          } else {
            print(
              'BusRouteMapPage: _geocodePlaceNameToLatLng - Parsing error for $pointType - lat: $lat, lon: $lon',
            );
          }
        } else {
          print(
            'BusRouteMapPage: _geocodePlaceNameToLatLng - No results found for $pointType',
          );
        }
      } else {
        print(
          'BusRouteMapPage: Nominatim API request failed for $pointType: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('BusRouteMapPage: Error during geocoding for $pointType: $e');
    }
    print(
      'BusRouteMapPage: _geocodePlaceNameToLatLng returning null for $pointType',
    );
    return null;
  }

  Future<void> _fetchRoutePolyline() async {
    print('BusRouteMapPage: _fetchRoutePolyline started');
    if (_startLocation == null || _endLocation == null) {
      print(
        'BusRouteMapPage: _fetchRoutePolyline - startLocation or endLocation is null, exiting',
      );
      return;
    }

    final startLat = _startLocation!.latitude;
    final startLng = _startLocation!.longitude;
    final endLat = _endLocation!.latitude;
    final endLng = _endLocation!.longitude;

    final orsDirectionsUrl = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car'
      '?api_key=$openRouteSerivceAPI'
      '&start=$startLng,$startLat&end=$endLng,$endLat',
    );

    print(
      'BusRouteMapPage: OpenRouteService Directions API URL: ${orsDirectionsUrl.toString()}',
    );

    try {
      final response = await http.get(orsDirectionsUrl);

      print(
        'BusRouteMapPage: OpenRouteService API response - Status Code: ${response.statusCode}',
      );
      print(
        'BusRouteMapPage: OpenRouteService API response - Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> features = data['features'];
        if (features.isNotEmpty) {
          final geometry = features[0]['geometry'];
          final List<dynamic> coordinates = geometry['coordinates'];
          if (mounted) {
            setState(() {
              _polylinePoints =
                  coordinates
                      .map((coord) => LatLng(coord[1], coord[0]))
                      .toList();
            });
          }
          print(
            'BusRouteMapPage: _fetchRoutePolyline - Polyline points fetched successfully, count: ${_polylinePoints.length}',
          );
        } else {
          print(
            'BusRouteMapPage: _fetchRoutePolyline - No route features found in ORS response.',
          );
        }
      } else {
        print(
          'BusRouteMapPage: OpenRouteService API request failed: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('BusRouteMapPage: Error fetching route polyline from ORS: $e');
    }
    print('BusRouteMapPage: _fetchRoutePolyline finished');
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.startingPointName} - ${widget.endingPointName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => MoreInfoScreen(
                        assignDataDocument: widget.assignDataDocument,
                        busDataDocument: widget.busDataDocument,
                      ),
                ),
              );
            },
          ),
          // Add a refresh button for manual updates
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // This is optional but helpful for testing
              _setupBusLocationListener();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing bus location data...'),
                ),
              );
            },
          ),
        ],
      ),
      body:
          (_startLocation == null ||
                  _endLocation == null ||
                  _busLocation == null ||
                  (!_isInBus &&
                      _userLocation ==
                          null)) // Conditionally check user location
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController, // Add the map controller
                    options: MapOptions(
                      initialCenter:
                          _busLocation ??
                          _startLocation ??
                          LatLng(11.004556, 76.961632),
                      initialZoom: 12.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          if (!_isInBus &&
                              _userLocation !=
                                  null) // Conditionally show user marker
                            Marker(
                              point: _userLocation!,
                              child: const Icon(
                                Icons.person_pin_circle, // User location icon
                                color: Color.fromARGB(255, 183, 0, 255),
                                size: 35.0,
                              ),
                            ),
                          if (_startLocation != null)
                            Marker(
                              point: _startLocation!,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.green,
                              ),
                            ),
                          if (_endLocation != null)
                            Marker(
                              point: _endLocation!,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                              ),
                            ),
                          if (_busLocation != null)
                            Marker(
                              point: _busLocation!,
                              child: const Icon(
                                Icons.directions_bus,
                                color: Colors.blue,
                                size: 30.0,
                              ),
                            ),
                        ],
                      ),
                      if (_polylinePoints.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _polylinePoints,
                              strokeWidth: 5.0,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                    ],
                  ),
                  Visibility(
                    visible: _polylinePoints.isEmpty,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Route could not be found for this bus route.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red[900],
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Live tracking indicator
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        'Live Tracking',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Add the center on bus button
                  Positioned(
                    bottom: 68,
                    right: 20,
                    child: CenterOnBusButton(onPressed: _centerOnBus),
                  ),
                  // White bar at the bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 50.0, // Adjust height as needed
                      color: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_eta.isNotEmpty)
                            Text(
                              _isInBus
                                  ? 'Estimated Time of Arrival: $_eta'
                                  : 'Estimated Time to Reach You: $_eta',
                              style: const TextStyle(fontSize: 16),
                            ),
                          if (_eta.isEmpty)
                            Text(
                              'Calculating ETA...',
                              style: const TextStyle(fontSize: 16),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
