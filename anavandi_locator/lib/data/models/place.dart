class Place {
  final String placeName;

  Place({required this.placeName});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(placeName: json['placeName'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'placeName': placeName};
  }
}
