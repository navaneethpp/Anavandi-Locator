import 'package:latlong2/latlong.dart'; // Import latlong2 for LatLng

class Bus {
  String? busDataId;
  String? busRegistrationNumber;
  String? engineNumber;
  String? frameNumber;
  String? modelName;
  String? ownerName;
  double? latitude; // Keep as double? but parse String from Firestore
  double? longitude; // Keep as double? but parse String from Firestore

  Bus({
    this.busDataId,
    this.busRegistrationNumber,
    this.engineNumber,
    this.frameNumber,
    this.modelName,
    this.ownerName,
    this.latitude,
    this.longitude,
  });

  factory Bus.fromJson(Map<String, dynamic> json, String id) {
    return Bus(
      busDataId: id,
      busRegistrationNumber: json['busRegistrationNumber'] as String?,
      engineNumber: json['engineNumber'] as String?,
      frameNumber: json['frameNumber'] as String?,
      modelName: json['modelName'] as String?,
      ownerName: json['ownerName'] as String?,
      // Parse latitude and longitude as String first, then try to convert to double
      latitude:
          json['latitude'] != null
              ? double.tryParse(json['latitude'].toString())
              : null,
      longitude:
          json['longitude'] != null
              ? double.tryParse(json['longitude'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'busRegistrationNumber': busRegistrationNumber,
      'engineNumber': engineNumber,
      'frameNumber': frameNumber,
      'modelName': modelName,
      'ownerName': ownerName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Helper method to get LatLng
  LatLng? get location {
    if (latitude != null && longitude != null) {
      return LatLng(latitude!, longitude!);
    }
    return null;
  }
}
