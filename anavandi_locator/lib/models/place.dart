class Place {
  String placeName;
  String? placeId; // Document ID from Firestore (optional, but helpful)

  Place({required this.placeName, this.placeId});

  factory Place.fromJson(Map<String, dynamic> json, String id) {
    return Place(
      placeName: json['placeName'] as String? ?? '',
      placeId: id, // Capture the document ID
    );
  }

  Map<String, dynamic> toJson() {
    return {'placeName': placeName};
  }
}
