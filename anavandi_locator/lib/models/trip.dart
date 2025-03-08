class Trip {
  String? tripDataId; // Document ID (optional)
  String? busStops;
  String? busType;
  String? depoName;
  String? endingTime;
  String? routeId;
  String? startingTime;
  String? status;
  String? tripId;

  Trip({
    this.tripDataId,
    this.busStops,
    this.busType,
    this.depoName,
    this.endingTime,
    this.routeId,
    this.startingTime,
    this.status,
    this.tripId,
  });

  factory Trip.fromJson(Map<String, dynamic> json, String id) {
    return Trip(
      tripDataId: id,
      busStops: json['busStops'] as String?,
      busType: json['busType'] as String?,
      depoName: json['depoName'] as String?,
      endingTime:
          json['ending Time']
              as String?, // Note: Firestore field name with space
      routeId: json['routeId'] as String?,
      startingTime:
          json['starting Time']
              as String?, // Note: Firestore field name with space
      status: json['status'] as String?,
      tripId: json['tripId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'busStops': busStops,
      'busType': busType,
      'depoName': depoName,
      'ending Time': endingTime, // Note: Firestore field name with space
      'routeId': routeId,
      'starting Time': startingTime, // Note: Firestore field name with space
      'status': status,
      'tripId': tripId,
    };
  }
}
