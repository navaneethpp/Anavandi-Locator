import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:anavandi_locator/data/models/bus_model.dart';
import 'package:anavandi_locator/presentation/widgets/center_bus_button.dart';
import 'package:anavandi_locator/services/bus_route_service.dart';
import 'package:anavandi_locator/services/osrm_service.dart';
import 'package:anavandi_locator/presentation/widgets/loading_indicator.dart';
import 'package:anavandi_locator/presentation/widgets/error_message_widget.dart';
import 'package:anavandi_locator/presentation/widgets/no_stops_warning.dart';
import 'package:anavandi_locator/utils/utils.dart';
import 'package:anavandi_locator/presentation/widgets/map_layers.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:anavandi_locator/presentation/widgets/data_display_widget.dart';
import 'dart:math';
import 'package:anavandi_locator/presentation/widgets/on_bus_confirmation_dialog.dart'; // Import the new dialog widget

class BusRouteMapScreen extends StatefulWidget {
  final String busRegistrationNumber;
  final String tripId;

  const BusRouteMapScreen({
    super.key,
    required this.busRegistrationNumber,
    required this.tripId,
  });

  @override
  State<BusRouteMapScreen> createState() => BusRouteMapScreenState();
}

class BusRouteMapScreenState extends State<BusRouteMapScreen> {
  Bus? _bus;
  final MapController _mapController = MapController();
  List<Marker> _stopMarkers = [];
  List<Polyline> _routePolylines = [];
  Timer? _locationUpdateTimer;
  bool _isLoading = true;
  bool _isLoadingRoute = false;
  String? _errorMessage;
  bool _showNoStopsWarning = false;
  bool _isDisposed = false;
  String? _startPoint;
  String? _destinationPoint;
  List<Map<String, dynamic>> _stopsData = [];
  bool _autoCenterEnabled = true;
  LatLng? _userLocation;
  String? _nearestStopName;
  String? _nextStopName; // New state variable for the next stop
  bool _showUserLocation = false; // New state variable
  bool _isOnBus = false; // New state variable to track if user is on the bus

  late final OnBusConfirmationDialog
  _onBusConfirmationDialog; // Declare without initialization

  @override
  void initState() {
    super.initState();
    print('BusRouteMapScreen initState called');
    _initializeData();
    _getCurrentUserLocation(); // Fetch location initially
    _calculateNearestStop();
    // Initialize the dialog here
    _onBusConfirmationDialog = OnBusConfirmationDialog(
      onConfirmation: _handleOnBusConfirmation,
    );
    // Show the confirmation dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onBusConfirmationDialog.show(context);
    });
  }

  void _handleOnBusConfirmation(bool isOnBus) {
    setState(() {
      _isOnBus = isOnBus;
      _showUserLocation = !isOnBus;
      _nearestStopName = null; // Reset these when bus status changes
      _nextStopName = null;
    });
    if (!_showUserLocation) {
      // If user is on the bus, we don't need continuous location updates
      _locationUpdateTimer?.cancel();
      _calculateNextStop(); // Calculate the next stop when user confirms they are on the bus
    } else {
      // If user is not on the bus, start or restart location updates
      _startLocationUpdates();
      _calculateNearestStop(); // Calculate the nearest stop when user confirms they are not on the bus
    }
  }

  @override
  void didUpdateWidget(covariant BusRouteMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('BusRouteMapScreen didUpdateWidget called');
    if (oldWidget.busRegistrationNumber != widget.busRegistrationNumber ||
        oldWidget.tripId != widget.tripId) {
      resetStateAndInitialize();
    } else {
      if (_locationUpdateTimer?.isActive == false ||
          _locationUpdateTimer == null) {
        _startLocationUpdates();
        if (!_isOnBus) {
          _calculateNearestStop();
        } else {
          _calculateNextStop();
        }
      }
      print(
        'BusRegistrationNumber and TripId are the same, keeping existing data.',
      );
    }
  }

  void resetStateAndInitialize() {
    print('BusRouteMapScreen _resetStateAndInitialize called');
    _bus = null;
    _stopMarkers.clear();
    _routePolylines.clear();
    _isLoading = true;
    _isLoadingRoute = false;
    _errorMessage = null;
    _showNoStopsWarning = false;
    _startPoint = null;
    _destinationPoint = null;
    _stopsData.clear();
    _autoCenterEnabled = true;
    _userLocation = null;
    _nearestStopName = null;
    _nextStopName = null;
    _isOnBus = false;
    _initializeData();
    _getCurrentUserLocation();
  }

  void _initializeData() async {
    if (_isDisposed) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _showNoStopsWarning = false;
        _startPoint = null;
        _destinationPoint = null;
        _stopsData.clear();
        _autoCenterEnabled = true;
        _nearestStopName = null;
        _nextStopName = null;
      });

      print('Fetching bus location for ${widget.busRegistrationNumber}');
      final fetchedBus = await BusRouteService.fetchBusLocation(
        widget.busRegistrationNumber,
      );
      if (mounted && !_isDisposed) {
        setState(() {
          _bus = fetchedBus;
          if (_autoCenterEnabled && _bus?.location != null) {
            try {
              _mapController.move(_bus!.location!, _mapController.camera.zoom);
            } catch (e) {
              print('Error moving map to initial bus location: $e');
            }
          }
        });
        print('Fetched bus: $_bus');
      }

      String? currentTripId = widget.tripId;
      if (currentTripId.isEmpty || currentTripId == '0') {
        print(
          'TripId not provided, fetching from assignData for ${widget.busRegistrationNumber}',
        );
        currentTripId = await BusRouteService.fetchTripIdFromAssignData(
          widget.busRegistrationNumber,
        );
        if (mounted && _bus != null && currentTripId != null && !_isDisposed) {
          setState(() {
            _bus!.tripId = currentTripId;
          });
          print('Fetched tripId from assignData: $_bus!.tripId');
        } else {
          print(
            'Could not fetch tripId from assignData for ${widget.busRegistrationNumber}',
          );
        }
      } else if (_bus != null) {
        _bus!.tripId = currentTripId;
        print('Using provided tripId: $_bus!.tripId');
      }

      if (_bus?.tripId != null) {
        final assignDataSnapshot =
            await FirebaseFirestore.instance
                .collection('assignData')
                .where('tripId', isEqualTo: _bus!.tripId!)
                .limit(1)
                .get();

        if (assignDataSnapshot.docs.isNotEmpty) {
          final assignData = assignDataSnapshot.docs.first.data();
          setState(() {
            _startPoint = assignData['startingPoint']?.toString();
            _destinationPoint = assignData['endingPoint']?.toString();
          });
          print(
            'Fetched start: $_startPoint, end: $_destinationPoint for tripId: ${_bus!.tripId!}',
          );
        } else {
          print('Warning: No assignData found for tripId: ${_bus!.tripId!}');
        }

        print('Fetching stops data for tripId: $_bus!.tripId');
        final fetchedStopsData = await BusRouteService.fetchBusStopsData(
          _bus!.tripId!,
        );
        if (fetchedStopsData != null && mounted && !_isDisposed) {
          print('Fetched stops data: $fetchedStopsData');
          setState(() {
            _stopsData = fetchedStopsData;
          });
          final markers = <Marker>[];
          final stopCoordinates = <LatLng>[];
          for (var stopData in fetchedStopsData) {
            final lat = stopData['latitude'];
            final lng = stopData['longitude'];
            final stopName = stopData['stopName']?.toString() ?? 'Stop';
            if (lat is num &&
                lng is num &&
                !lat.isNaN &&
                !lng.isNaN &&
                lat.isFinite &&
                lng.isFinite) {
              final latLng = LatLng(lat.toDouble(), lng.toDouble());
              if (isValidCoordinate(latLng.latitude, latLng.longitude)) {
                stopCoordinates.add(latLng);
                markers.add(
                  Marker(
                    point: latLng,
                    width: 200,
                    height: 60,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 20,
                        ),
                        Text(
                          stopName,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            backgroundColor: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                print(
                  'Valid stop coordinate added: $latLng with name: $stopName',
                );
              } else {
                print(
                  'Warning: Invalid coordinate found: Latitude=$lat, Longitude=$lng',
                );
              }
            } else {
              print(
                'Warning: Latitude or Longitude is not a number or is null in stop data: $stopData',
              );
            }
          }
          setState(() {
            _stopMarkers = markers;
            _showNoStopsWarning = markers.isEmpty;
          });
          print('Number of valid stop markers: ${_stopMarkers.length}');
          print(
            'Stop Coordinates for route: $stopCoordinates',
          ); // Log stop coordinates

          if (stopCoordinates.length >= 2) {
            print('Generating route polylines from stop coordinates');
            await _generateRoutePolylines(stopCoordinates);
          } else if (_bus?.location != null && stopCoordinates.isNotEmpty) {
            print('Generating route polylines from bus and stop coordinates');
            final points = [_bus!.location!, ...stopCoordinates];
            await _generateRoutePolylines(points);
          } else if (_bus?.location != null &&
              stopCoordinates.isEmpty &&
              currentTripId != null) {
            final assignDataSnapshot =
                await FirebaseFirestore.instance
                    .collection('assignData')
                    .where('tripId', isEqualTo: currentTripId)
                    .limit(1)
                    .get();
            if (assignDataSnapshot.docs.isNotEmpty) {
              final routeId =
                  assignDataSnapshot.docs.first.data()['routeId']?.toString();
              if (routeId != null) {
                final routeStopsData =
                    await BusRouteService.fetchRouteStopsByRouteId(routeId);
                if (routeStopsData != null) {
                  final routeCoordinates = <LatLng>[];
                  for (var stopData in routeStopsData) {
                    final lat = stopData['latitude'];
                    final lng = stopData['longitude'];
                    if (lat is num &&
                        lng is num &&
                        !lat.isNaN &&
                        !lng.isNaN &&
                        lat.isFinite &&
                        lng.isFinite) {
                      final latLng = LatLng(lat.toDouble(), lng.toDouble());
                      if (isValidCoordinate(
                        latLng.latitude,
                        latLng.longitude,
                      )) {
                        routeCoordinates.add(latLng);
                      }
                    }
                  }
                  print(
                    'Route Coordinates from routeId: $routeCoordinates',
                  ); // Log route coordinates
                  if (routeCoordinates.length >= 2) {
                    print(
                      'Generating route polylines from route coordinates (routeId)',
                    );
                    await _generateRoutePolylines(routeCoordinates);
                  } else {
                    print(
                      'Warning: Less than 2 valid coordinates in route data (routeId)',
                    );
                  }
                } else {
                  print(
                    'Warning: Could not fetch route stops data for routeId: $routeId',
                  );
                }
              } else {
                print('Warning: routeId is null in assignData');
              }
            } else {
              print('Warning: No assignData found for tripId: $currentTripId');
            }
          } else {
            print('Warning: No stops found and cannot fetch route by routeId');
          }
        } else if (mounted && !_isDisposed) {
          setState(() {
            _showNoStopsWarning = true;
            _nearestStopName = null;
            _nextStopName = null;
          });
          print(
            'Warning: Could not fetch bus stops data for tripId: $_bus!.tripId',
          );
        }
      } else if (mounted && !_isDisposed) {
        setState(() {
          _errorMessage = 'Could not find trip information for this bus';
          _nearestStopName = null;
          _nextStopName = null;
        });
        print(
          'Error: Could not find trip information for bus ${widget.busRegistrationNumber}',
        );
      }
    } catch (e) {
      print('Error initializing data: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _errorMessage = 'Failed to load bus data: $e';
          _nearestStopName = null;
          _nextStopName = null;
        });
      }
    } finally {
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
        });
      }
      _startLocationUpdates();
      if (_isOnBus) {
        _calculateNextStop();
      } else {
        _calculateNearestStop();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _locationUpdateTimer?.cancel();
    print('BusRouteMapScreen dispose called');
    super.dispose();
  }

  void _startLocationUpdates() {
    if (_isDisposed) return;
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      final fetchedBus = await BusRouteService.fetchBusLocation(
        widget.busRegistrationNumber,
      );
      if (mounted && !_isDisposed && fetchedBus != null) {
        setState(() {
          _bus = fetchedBus;
          if (_autoCenterEnabled && _bus?.location != null) {
            try {
              _mapController.move(
                fetchedBus.location!,
                _mapController.camera.zoom,
              );
            } catch (e) {
              print('Error moving map on update: $e');
            }
          }
        });
        if (_isOnBus) {
          _calculateNextStop();
        }
      }
    });
  }

  Future<void> _generateRoutePolylines(List<LatLng> coordinates) async {
    if (_isDisposed) return;
    if (coordinates.length < 2) {
      print('Cannot generate route, less than 2 coordinates provided');
      return;
    }

    if (mounted && !_isDisposed) {
      setState(() {
        _isLoadingRoute = true;
      });
    }

    try {
      final List<Polyline> polylines = [];
      for (int i = 0; i < coordinates.length - 1; i++) {
        final start = coordinates[i];
        final end = coordinates[i + 1];

        if (!isValidCoordinate(start.latitude, start.longitude) ||
            !isValidCoordinate(end.latitude, end.longitude)) {
          print('Skipping invalid coordinate pair for OSRM: $start to $end');
          continue;
        }

        final routePoints = await OSRMService.fetchRoute(start, end);

        if (routePoints.isNotEmpty) {
          polylines.add(
            Polyline(
              points: routePoints,
              strokeWidth: 4.0,
              color: Colors.blue.withOpacity(0.7),
            ),
          );
        } else {
          polylines.add(
            Polyline(
              points: [start, end],
              strokeWidth: 3.0,
              color: Colors.red.withOpacity(0.5),
            ),
          );
          print(
            'OSRM returned empty route, using direct line from $start to $end',
          );
        }
      }

      if (mounted && !_isDisposed) {
        setState(() {
          _routePolylines = polylines;
          _isLoadingRoute = false;
        });
      }
      print(
        'Number of route polylines: ${_routePolylines.length}',
      ); // Log the number of polylines
    } catch (e) {
      print('Error generating route polylines: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoadingRoute = false;
          if (coordinates.length >= 2) {
            _routePolylines = [
              Polyline(
                points: coordinates,
                strokeWidth: 3.0,
                color: Colors.red.withOpacity(0.5),
              ),
            ];
            print(
              'Fallback to direct line between all points due to error: $e',
            );
          }
        });
      }
    }
  }

  Future<void> _getCurrentUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted && !_isDisposed) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable them.';
          _nearestStopName = null;
          _nextStopName = null;
        });
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted && !_isDisposed) {
          setState(() {
            _errorMessage =
                'Location permissions are denied. Please grant them to use this feature.';
            _nearestStopName = null;
            _nextStopName = null;
          });
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted && !_isDisposed) {
        setState(() {
          _errorMessage =
              'Location permissions are permanently denied. Please enable them in your device settings.';
          _nearestStopName = null;
          _nextStopName = null;
        });
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted && !_isDisposed) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
        print('User location: $_userLocation');
        if (!_isOnBus) {
          _calculateNearestStop();
        }
      }
    } catch (e) {
      print('Error getting user location: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _errorMessage = 'Failed to get user location: $e';
          _nearestStopName = null;
          _nextStopName = null;
        });
      }
    }
  }

  Future<void> _calculateNearestStop() async {
    if (_userLocation == null || _stopsData.isEmpty || _isOnBus) {
      setState(() {
        _nearestStopName = null;
      });
      return;
    }

    LatLng nearestStopPoint = LatLng(0, 0);
    double minDistance = double.infinity;
    String? nearestStop;

    for (var stopData in _stopsData) {
      final lat = stopData['latitude'];
      final lng = stopData['longitude'];
      final stopName = stopData['stopName']?.toString();

      if (lat is num && lng is num) {
        final stopLatLng = LatLng(lat.toDouble(), lng.toDouble());
        final distance = calculateDistance(_userLocation!, stopLatLng);
        if (distance < minDistance) {
          minDistance = distance;
          nearestStopPoint = stopLatLng;
          nearestStop = stopName;
        }
      }
    }

    setState(() {
      _nearestStopName = nearestStop;
    });
    print('Nearest stop: $_nearestStopName');
  }

  Future<void> _calculateNextStop() async {
    if (_bus?.location == null || _stopsData.isEmpty || !_isOnBus) {
      setState(() {
        _nextStopName = null;
      });
      return;
    }

    double minDistance = double.infinity;
    int closestStopIndex = -1;

    for (int i = 0; i < _stopsData.length; i++) {
      final stopData = _stopsData[i];
      final lat = stopData['latitude'];
      final lng = stopData['longitude'];

      if (lat is num && lng is num) {
        final stopLatLng = LatLng(lat.toDouble(), lng.toDouble());
        final distance = calculateDistance(_bus!.location!, stopLatLng);
        if (distance < minDistance) {
          minDistance = distance;
          closestStopIndex = i;
        }
      }
    }

    if (closestStopIndex != -1 && closestStopIndex < _stopsData.length - 1) {
      setState(() {
        _nextStopName =
            _stopsData[closestStopIndex + 1]['stopName']?.toString();
      });
      print('Next stop: $_nextStopName');
    } else {
      setState(() {
        _nextStopName = 'End of Route';
      });
      print('Next stop: End of Route');
    }
  }

  double calculateDistance(LatLng point1, LatLng point2) {
    const R = 6371e3;
    final lat1 = point1.latitude * pi / 180;
    final lon1 = point1.longitude * pi / 180;
    final lat2 = point2.latitude * pi / 180;
    final lon2 = point2.longitude * pi / 180;

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  @override
  Widget build(BuildContext context) {
    print('Checking conditions for More Info button:');
    print('  _bus?.tripId: ${_bus?.tripId}');
    print('  _startPoint: $_startPoint');
    print('  _destinationPoint: $_destinationPoint');
    print('  _stopsData.isNotEmpty: ${_stopsData.isNotEmpty}');
    print('Number of route polylines in build: ${_routePolylines.length}');
    print('User on bus: $_isOnBus');

    // Prepare user location marker
    List<Marker> userLocationMarkers = [];
    if (_userLocation != null && _showUserLocation) {
      userLocationMarkers.add(
        Marker(
          point: _userLocation!,
          width: 20,
          height: 20,
          child: const Icon(
            Icons.person_pin_circle,
            color: Colors.green,
            size: 30,
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _bus?.location ?? LatLng(0, 0),
              initialZoom: 16,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _autoCenterEnabled = false;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              // Use the MapLayers widget here
              MapLayers(
                bus: _bus,
                stopMarkers: _stopMarkers,
                routePolylines: _routePolylines,
                userLocation:
                    _showUserLocation
                        ? _userLocation
                        : null, // Pass userLocation conditionally
              ),
              MarkerLayer(
                // Add the MarkerLayer
                markers: userLocationMarkers,
              ),
            ],
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: const Text(
              "OpenStreetMapContributes",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          if (_isLoading || _isLoadingRoute) const LoadingIndicator(),
          if (_errorMessage != null)
            ErrorMessageWidget(message: _errorMessage!),
          if (_showNoStopsWarning &&
              !_isLoading &&
              !_isLoadingRoute &&
              _errorMessage == null)
            const NoStopsWarning(),
          Positioned(
            bottom: 16,
            right: 16,
            child:
                _bus?.location != null && !_isLoading
                    ? CenterBusButton(
                      mapController: _mapController,
                      busLocation: _bus?.location,
                    )
                    : const SizedBox.shrink(),
          ),
          Positioned(
            top: 16,
            right: 0,
            child: DataDisplayWidget(
              stopName:
                  _isOnBus
                      ? _nextStopName
                      : _nearestStopName, // Conditional display
              isNextStop: _isOnBus, // Pass a flag to the widget
            ),
          ),
        ],
      ),
    );
  }
}
