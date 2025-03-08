class Depo {
  String? depoDataId; // Document ID (optional)
  String? depoName;
  String? email;
  String? uid; // User ID, seems to be the same as document ID in this case

  Depo({this.depoDataId, this.depoName, this.email, this.uid});

  factory Depo.fromJson(Map<String, dynamic> json, String id) {
    return Depo(
      depoDataId: id, // Document ID
      depoName: json['depoName'] as String?,
      email: json['email'] as String?,
      uid: json['uid'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'depoName': depoName, 'email': email, 'uid': uid};
  }
}
