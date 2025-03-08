class Route {
  String? routeDataId; // Document ID (optional)
  String? depoName;
  String? endingPoint;
  String?
  routeId; // It seems like routeId in Firestore is a String, not a number
  String?
  runningKilometer; // Keep as String to match Firestore, could be double or int
  String? startingPoint;
  String? status;
  String? totalTrips; // Keep as String to match Firestore, could be int
  int? tripAdded; // Integer in Firestore

  Route({
    this.routeDataId,
    this.depoName,
    this.endingPoint,
    this.routeId,
    this.runningKilometer,
    this.startingPoint,
    this.status,
    this.totalTrips,
    this.tripAdded,
  });

  factory Route.fromJson(Map<String, dynamic> json, String id) {
    return Route(
      routeDataId: id,
      depoName: json['depoName'] as String?,
      endingPoint: json['endingPoint'] as String?,
      routeId: json['routeId'] as String?,
      runningKilometer: json['runningKilometer'] as String?,
      startingPoint: json['startingPoint'] as String?,
      status: json['status'] as String?,
      totalTrips: json['totalTrips'] as String?,
      tripAdded: json['tripAdded'] as int?, // Parse as int
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'depoName': depoName,
      'endingPoint': endingPoint,
      'routeId': routeId,
      'runningKilometer': runningKilometer,
      'startingPoint': startingPoint,
      'status': status,
      'totalTrips': totalTrips,
      'tripAdded': tripAdded,
    };
  }
}
