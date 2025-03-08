// import 'package:cloud_firestore/cloud_firestore.dart';

class Staff {
  String? staffDataId; // Document ID (optional)
  String? address;
  String? contactNumber;
  String? depoName;
  String? designation;
  String?
  dob; // Kept as String to match Firestore, consider DateTime for date operations
  String?
  joiningDate; // Kept as String to match Firestore, consider DateTime for date operations
  String? licenseNumber;
  String? name;
  String? staffId;
  String? status;

  Staff({
    this.staffDataId,
    this.address,
    this.contactNumber,
    this.depoName,
    this.designation,
    this.dob,
    this.joiningDate,
    this.licenseNumber,
    this.name,
    this.staffId,
    this.status,
  });

  factory Staff.fromJson(Map<String, dynamic> json, String id) {
    return Staff(
      staffDataId: id,
      address: json['address'] as String?,
      contactNumber: json['contactNumber'] as String?,
      depoName: json['depoName'] as String?,
      designation: json['designation'] as String?,
      dob: json['dob'] as String?,
      joiningDate:
          json['joining Date']
              as String?, // Note: Firestore field name with space
      licenseNumber: json['licenseNumber'] as String?,
      name: json['name'] as String?,
      staffId: json['staffId'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'contactNumber': contactNumber,
      'depoName': depoName,
      'designation': designation,
      'dob': dob,
      'joining Date': joiningDate, // Note: Firestore field name with space
      'licenseNumber': licenseNumber,
      'name': name,
      'staffId': staffId,
      'status': status,
    };
  }
}
