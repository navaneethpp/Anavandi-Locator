import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:anavandi_locator/api/open_route_service.dart'; // Assuming your API key is here

class BusRoutePolyline extends StatefulWidget {
  final List<LatLng> busStopCoordinates;

  const BusRoutePolyline({super.key, required this.busStopCoordinates});

  @override
  State<BusRoutePolyline> createState() => _BusRoutePolylineState();
}

class _BusRoutePolylineState extends State<BusRoutePolyline> {
  List<LatLng> _polylinePoints = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    if (widget.busStopCoordinates.length < 2) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'At least two bus stops are needed to draw a route.';
      });
      return;
    }

    final List<List<double>> coordinates =
        widget.busStopCoordinates
            .map((latLng) => [latLng.longitude, latLng.latitude])
            .toList();

    final String coordinatesString = jsonEncode(coordinates);

    final String url =
        'https://api.openrouteservice.com/v2/directions/driving-car?api_key=$openRouteSerivceAPI&coordinates=$coordinatesString';

    print('OpenRouteService API URL: $url'); // For debugging

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List?;
        if (features != null && features.isNotEmpty) {
          final geometry = features[0]['geometry'];
          if (geometry != null && geometry['type'] == 'LineString') {
            final List<dynamic> rawCoordinates = geometry['coordinates'];
            final List<LatLng> points =
                rawCoordinates
                    .map(
                      (coord) =>
                          LatLng(coord[1].toDouble(), coord[0].toDouble()),
                    )
                    .toList();
            setState(() {
              _polylinePoints = points;
              _isLoading = false;
            });
            return;
          }
        }
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to parse route data.';
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to fetch route: Status code ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching route: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    if (_polylinePoints.isNotEmpty) {
      return PolylineLayer(
        polylines: [
          Polyline(points: _polylinePoints, color: Colors.blue, strokeWidth: 3),
        ],
      );
    }
    return const SizedBox.shrink(); // Return an empty widget if no route to display
  }
}
