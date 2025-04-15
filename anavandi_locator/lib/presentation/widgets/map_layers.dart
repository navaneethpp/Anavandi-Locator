import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:anavandi_locator/data/models/bus_model.dart';
import 'package:anavandi_locator/utils/utils.dart';

class MapLayers extends StatelessWidget {
  final Bus? bus;
  final List<Marker> stopMarkers;
  final List<Polyline> routePolylines;
  final LatLng? userLocation;

  const MapLayers({
    super.key,
    this.bus,
    required this.stopMarkers,
    required this.routePolylines,
    this.userLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // First add the polylines
        PolylineLayer(polylines: routePolylines),

        // Then add stop markers
        MarkerLayer(markers: stopMarkers),

        // Then add the bus marker (it will appear on top of stops)
        if (bus?.location != null &&
            isValidCoordinate(
              bus!.location!.latitude,
              bus!.location!.longitude,
            ))
          MarkerLayer(
            markers: [
              Marker(
                point: bus!.location!,
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

        // Finally add user location marker if available
        if (userLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: userLocation!,
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
      ],
    );
  }
}
