import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CenterBusButton extends StatelessWidget {
  final MapController mapController;
  final LatLng? busLocation;

  const CenterBusButton({
    super.key,
    required this.mapController,
    this.busLocation,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        if (busLocation != null) {
          mapController.move(busLocation!, 20.0);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bus location not available yet.')),
          );
        }
      },
      child: const Icon(Icons.my_location),
    );
  }
}
