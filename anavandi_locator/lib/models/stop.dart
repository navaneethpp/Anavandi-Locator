import 'package:latlong2/latlong.dart'; // Import latlong2 for LatLng

class Stop {
  String? stopDataId; // Document ID (optional)
  // Add fields based on your 'stopData' document structure
  // Example fields (you'll need to adjust these):
  String? stopName;
  double? latitude;
  double? longitude;

  Stop({this.stopDataId, this.stopName, this.latitude, this.longitude});

  factory Stop.fromJson(Map<String, dynamic> json, String id) {
    return Stop(
      stopDataId: id,
      stopName: json['stopName'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'stopName': stopName, 'latitude': latitude, 'longitude': longitude};
  }

  // Helper method to get LatLng
  LatLng? get location {
    if (latitude != null && longitude != null) {
      return LatLng(latitude!, longitude!);
    }
    return null;
  }
}
