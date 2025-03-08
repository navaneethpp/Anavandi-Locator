import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  String? complaintDataId; // Document ID (optional)
  String? busRegistrationNumber;
  String? complaintDetails;
  String? complaintPart;
  String? currentPlace;
  String? depoName;
  DateTime? timestamp;

  Complaint({
    this.complaintDataId,
    this.busRegistrationNumber,
    this.complaintDetails,
    this.complaintPart,
    this.currentPlace,
    this.depoName,
    this.timestamp,
  });

  factory Complaint.fromJson(Map<String, dynamic> json, String id) {
    return Complaint(
      complaintDataId: id,
      busRegistrationNumber: json['busRegistrationNumber'] as String?,
      complaintDetails: json['complaintDetails'] as String?,
      complaintPart: json['complaintPart'] as String?,
      currentPlace: json['currentPlace'] as String?,
      depoName: json['depoName'] as String?,
      timestamp:
          json['timestamp'] != null
              ? (json['timestamp'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'busRegistrationNumber': busRegistrationNumber,
      'complaintDetails': complaintDetails,
      'complaintPart': complaintPart,
      'currentPlace': currentPlace,
      'depoName': depoName,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
    };
  }
}
