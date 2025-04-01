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
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anavandi_locator/presentation/widgets/refresh_button.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator package

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
  List<Map<String, dynamic>> _stopsData = []; // To store fetched stops data
  bool _autoCenterEnabled = true; // New state variable
  LatLng? _userLocation; // New state variable for user location

  @override
  void initState() {
    super.initState();
    print('BusRouteMapScreen initState called');
    _initializeData();
    _getCurrentUserLocation(); // Call to get user's location
  }

  @override
  void didUpdateWidget(covariant BusRouteMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('BusRouteMapScreen didUpdateWidget called');
    if (oldWidget.busRegistrationNumber != widget.busRegistrationNumber ||
        oldWidget.tripId != widget.tripId) {
      resetStateAndInitialize(); // Calling the now public method
    } else {
      if (_locationUpdateTimer?.isActive == false ||
          _locationUpdateTimer == null) {
        _startLocationUpdates();
      }
      print(
        'BusRegistrationNumber and TripId are the same, keeping existing data.',
      );
    }
  }

  void resetStateAndInitialize() {
    // Removed the underscore here
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
    _autoCenterEnabled = true; // Reset auto-center on re-initialize
    _userLocation = null; // Reset user location
    _initializeData();
    _getCurrentUserLocation(); // Re-fetch user location
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
        _autoCenterEnabled = true; // Enable auto-center initially
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

          if (stopCoordinates.length >= 2) {
            await _generateRoutePolylines(stopCoordinates);
          } else if (_bus?.location != null && stopCoordinates.isNotEmpty) {
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
                  if (routeCoordinates.length >= 2) {
                    await _generateRoutePolylines(routeCoordinates);
                  } else {
                    print(
                      'Warning: Less than 2 valid coordinates in route data',
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
          });
          print(
            'Warning: Could not fetch bus stops data for tripId: $_bus!.tripId',
          );
        }
      } else if (mounted && !_isDisposed) {
        setState(() {
          _errorMessage = 'Could not find trip information for this bus';
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
        });
      }
    } finally {
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
        });
      }
      _startLocationUpdates();
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

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted && !_isDisposed) {
        setState(() {
          _errorMessage =
              'Location services are disabled. Please enable them in your device settings.';
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
          });
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted && !_isDisposed) {
        setState(() {
          _errorMessage =
              'Location permissions are permanently denied. Please enable them in your app settings.';
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
      }
    } catch (e) {
      print('Error getting user location: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _errorMessage = 'Failed to get user location: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Checking conditions for More Info button:');
    print('  _bus?.tripId: ${_bus?.tripId}');
    print('  _startPoint: $_startPoint');
    print('  _destinationPoint: $_destinationPoint');
    print('  _stopsData.isNotEmpty: ${_stopsData.isNotEmpty}');

    Widget appBarTitleWidget;
    if (_startPoint != null && _destinationPoint != null) {
      appBarTitleWidget = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_startPoint to $_destinationPoint',
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            widget.busRegistrationNumber,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      );
    } else {
      appBarTitleWidget = Text('Route for ${widget.busRegistrationNumber}');
    }

    return Stack(
      // Removed Scaffold and AppBar
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
            MarkerLayer(
              markers: [
                if (_bus?.location != null)
                  Marker(
                    point: _bus!.location!,
                    width: 20,
                    height: 20,
                    child: const Icon(
                      Icons.directions_bus,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                ..._stopMarkers,
                if (_userLocation != null) // Add user location marker
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
              ],
            ),
            PolylineLayer(polylines: _routePolylines),
          ],
        ),
        if (_isLoading || _isLoadingRoute) const LoadingIndicator(),
        if (_errorMessage != null) ErrorMessageWidget(message: _errorMessage!),
        if (_showNoStopsWarning &&
            !_isLoading &&
            !_isLoadingRoute &&
            _errorMessage == null)
          const NoStopsWarning(),
        Positioned(
          bottom: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_bus?.location != null && !_isLoading)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _autoCenterEnabled = true;
                      if (_bus?.location != null) {
                        _mapController.move(
                          _bus!.location!,
                          _mapController.camera.zoom,
                        );
                      }
                    });
                  },
                  child: CenterBusButton(
                    mapController: _mapController,
                    busLocation: _bus?.location,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
