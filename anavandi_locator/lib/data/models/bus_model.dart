import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class Bus {
  final String? busRegistrationNumber;
  final LatLng? location;
  final String? busType;
  final String? conductorName;
  final String? depoName;
  final String? driverName;
  final String? endingPoint;
  final String? endingTime;
  final String? routeId;
  final String? startingPoint;
  final String? startingTime;
  String? tripId;

  Bus({
    this.busRegistrationNumber,
    this.location,
    this.busType,
    this.conductorName,
    this.depoName,
    this.driverName,
    this.endingPoint,
    this.endingTime,
    this.routeId,
    this.startingPoint,
    this.startingTime,
    required this.tripId,
  });

  Bus copyWith({
    String? busRegistrationNumber,
    LatLng? location,
    String? tripId,
  }) {
    return Bus(
      busRegistrationNumber:
          busRegistrationNumber ?? this.busRegistrationNumber,
      location: location ?? this.location,
      tripId: tripId ?? this.tripId,
    );
  }

  factory Bus.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    print("Hello data: $data");
    return Bus(
      busRegistrationNumber: data?['busRegistrationNumber'] as String?,
      location:
          data?['location'] != null
              ? LatLng(
                (data?['location'] as List)[0].toDouble(),
                (data?['location'] as List)[1].toDouble(),
              )
              : null,
      busType: data?['busType'] as String?,
      conductorName: data?['conductorName'] as String?,
      depoName: data?['depoName'] as String?,
      driverName: data?['driverName'] as String?,
      endingPoint: data?['endingPoint'] as String?,
      endingTime: data?['endingTime'] as String?,
      routeId: data?['routeId'] as String?,
      startingPoint: data?['startingPoint'] as String?,
      startingTime: data?['startingTime'] as String?,
      tripId: data?['tripId'] as String?,
    );
  }
}
