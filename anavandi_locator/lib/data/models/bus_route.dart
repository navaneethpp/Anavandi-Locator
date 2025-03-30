class BusRoute {
  final String startingPoint;
  final String endingPoint;
  final String startingTime;
  final String endingTime;
  final String busType;
  final String busRegistrationNumber;
  final String routeId;
  final String tripId;
  final List<BusStop> busStops;

  BusRoute({
    required this.startingPoint,
    required this.endingPoint,
    required this.startingTime,
    required this.endingTime,
    required this.busType,
    required this.busRegistrationNumber,
    required this.routeId,
    required this.tripId,
    required this.busStops,
  });
}

class BusStop {
  final String stopName;
  final String stopTime;

  BusStop({required this.stopName, required this.stopTime});

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      stopName: json['stopName'] as String,
      stopTime: json['stopTime'] as String,
    );
  }
}
