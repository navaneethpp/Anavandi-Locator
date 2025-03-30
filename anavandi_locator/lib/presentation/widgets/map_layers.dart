import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:anavandi_locator/data/models/bus_model.dart';
import 'package:anavandi_locator/utils/utils.dart';

class _MapLayers extends StatelessWidget {
  final Bus? bus;
  final List<Marker> stopMarkers;
  final List<Polyline> routePolylines;

  const _MapLayers({
    this.bus,
    required this.stopMarkers,
    required this.routePolylines,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PolylineLayer(polylines: routePolylines),
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
        MarkerLayer(markers: stopMarkers),
      ],
    );
  }
}
