import 'package:cloud_firestore/cloud_firestore.dart';

class AssignData {
  String? assignDataId; // Document ID (optional)
  String? busRegistrationNumber;
  String? routeId;
  DateTime?
  assignmentTime; // Changed from assignmentDate to assignmentTime to match Firestore
  String? conductorName; // Added conductorName
  String? depoName; // Added depoName
  String? driverName; // Added driverName
  String? endingPoint; // Added endingPoint
  String? endingTime; // Added endingTime
  String? startingPoint; // Added startingPoint
  String? startingTime; // Added startingTime
  String? tripId; // Added tripId

  AssignData({
    this.assignDataId,
    this.busRegistrationNumber,
    this.routeId,
    this.assignmentTime,
    this.conductorName,
    this.depoName,
    this.driverName,
    this.endingPoint,
    this.endingTime,
    this.startingPoint,
    this.startingTime,
    this.tripId,
  });

  factory AssignData.fromJson(Map<String, dynamic> json, String id) {
    return AssignData(
      assignDataId: id,
      busRegistrationNumber: json['busRegistrationNumber'] as String?,
      routeId: json['routeId'] as String?,
      assignmentTime:
          json['assignmentTime'] != null
              ? (json['assignmentTime'] as Timestamp).toDate()
              : null, // Use assignmentTime from Firestore
      conductorName:
          json['conductor Name']
              as String?, // Use "conductor Name" to match Firestore
      depoName: json['depoName'] as String?,
      driverName: json['driverName'] as String?,
      endingPoint: json['endingPoint'] as String?,
      endingTime:
          json['ending Time']
              as String?, // Use "ending Time" to match Firestore
      startingPoint: json['startingPoint'] as String?,
      startingTime: json['startingTime'] as String?,
      tripId: json['tripId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'busRegistrationNumber': busRegistrationNumber,
      'routeId': routeId,
      'assignmentTime':
          assignmentTime != null
              ? Timestamp.fromDate(assignmentTime!)
              : null, // Use assignmentTime
      'conductor Name':
          conductorName, // Use "conductor Name" to match Firestore
      'depoName': depoName,
      'driverName': driverName,
      'endingPoint': endingPoint,
      'ending Time': endingTime, // Use "ending Time" to match Firestore
      'startingPoint': startingPoint,
      'startingTime': startingTime,
      'tripId': tripId,
    };
  }
}
