class Place {
  final String placeName;
  final double? latitude;
  final double? longitude;

  Place({required this.placeName, this.latitude, this.longitude});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      placeName: json['placeName'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeName': placeName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
