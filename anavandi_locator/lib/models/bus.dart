// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart'; // Import latlong2 for LatLng

class Bus {
  String? busDataId; // Document ID (optional)
  String? busRegistrationNumber;
  String? busType;
  String? busUniqueNumber;
  String? chassisNumber;
  String? depoName;
  String? engineNumber;
  String?
  expireDate; // Keep as String to match Firestore, consider DateTime for date operations
  String? gpsId;
  String?
  isComplaint; // Keep as String "yes" or "no" to match Firestore, consider boolean
  double? latitude;
  double? longitude;
  String?
  manufactureDate; // Keep as String to match Firestore, consider DateTime for date operations
  String? manufacturePlace;
  String? model;
  double? speed;
  String? status;
  double? totalKmRunned;

  Bus({
    this.busDataId,
    this.busRegistrationNumber,
    this.busType,
    this.busUniqueNumber,
    this.chassisNumber,
    this.depoName,
    this.engineNumber,
    this.expireDate,
    this.gpsId,
    this.isComplaint,
    this.latitude,
    this.longitude,
    this.manufactureDate,
    this.manufacturePlace,
    this.model,
    this.speed,
    this.status,
    this.totalKmRunned,
  });

  factory Bus.fromJson(Map<String, dynamic> json, String id) {
    List<dynamic>? locationArray = json['location'] as List<dynamic>?;
    double? lat, lon;
    if (locationArray != null && locationArray.length == 2) {
      lat = double.tryParse(locationArray[0].toString());
      lon = double.tryParse(locationArray[1].toString());
    }

    return Bus(
      busDataId: id,
      busRegistrationNumber: json['busRegistrationNumber'] as String?,
      busType: json['busType'] as String?,
      busUniqueNumber: json['busUniqueNumber'] as String?,
      chassisNumber: json['chassisNumber'] as String?,
      depoName: json['depoName'] as String?,
      engineNumber: json['engineNumber'] as String?,
      expireDate: json['expireDate'] as String?,
      gpsId: json['gpsId'] as String?,
      isComplaint: json['isComplaint'] as String?,
      latitude: lat,
      longitude: lon,
      manufactureDate: json['manufactureDate'] as String?,
      manufacturePlace: json['manufacturePlace'] as String?,
      model: json['model'] as String?,
      speed: json['speed'] as double?,
      status: json['status'] as String?,
      totalKmRunned: json['totalKmRunned'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'busRegistrationNumber': busRegistrationNumber,
      'busType': busType,
      'busUniqueNumber': busUniqueNumber,
      'chassisNumber': chassisNumber,
      'depoName': depoName,
      'engineNumber': engineNumber,
      'expireDate': expireDate,
      'gpsId': gpsId,
      'isComplaint': isComplaint,
      'location': [latitude, longitude], // Create location array for Firestore
      'manufactureDate': manufactureDate,
      'manufacturePlace': manufacturePlace,
      'model': model,
      'speed': speed,
      'status': status,
      'totalKmRunned': totalKmRunned,
    };
  }

  // Helper method to get LatLng for map markers
  LatLng? get location {
    if (latitude != null && longitude != null) {
      return LatLng(latitude!, longitude!);
    }
    return null;
  }
}
