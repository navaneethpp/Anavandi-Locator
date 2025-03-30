import 'package:latlong2/latlong.dart';

class BusStop {
  final double latitude;
  final double longitude;
  final String stopName;
  final String stopTime;

  BusStop({
    required this.latitude,
    required this.longitude,
    required this.stopName,
    required this.stopTime,
  });

  factory BusStop.fromMap(Map<String, dynamic> map) {
    print("Longitude: ");
    return BusStop(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      stopName: map['stopName'] as String? ?? '',
      stopTime: map['stopTime'] as String? ?? '',
    );
  }
  LatLng get location => LatLng(latitude, longitude);
}
