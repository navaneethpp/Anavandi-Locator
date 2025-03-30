import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OpenStreetMapWidget extends StatefulWidget {
  final LatLng? initialCenter;
  final double initialZoom;
  final List<Widget> layers;
  final MapController? mapController; // Add this

  const OpenStreetMapWidget({
    super.key,
    this.initialCenter,
    this.initialZoom = 16.0,
    this.layers = const [],
    this.mapController, // Add this
  });

  @override
  State<OpenStreetMapWidget> createState() => _OpenStreetMapWidgetState();
}

class _OpenStreetMapWidgetState extends State<OpenStreetMapWidget> {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: widget.mapController, // Use the passed controller
      options: MapOptions(
        initialCenter: widget.initialCenter ?? const LatLng(20.5937, 78.9629),
        initialZoom: widget.initialZoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        ...widget.layers,
      ],
    );
  }
}
