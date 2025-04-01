import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/svg.dart';

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
          mapController.move(busLocation!, 16.0);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bus location not available yet.')),
          );
        }
      },
      child: SvgPicture.asset(
        'assets/icon/recenter.svg',
        color: Colors.indigo,
        width: 30,
        height: 30,
      ),
    );
  }
}
