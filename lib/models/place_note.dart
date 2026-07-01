class PlaceNote {
  const PlaceNote({
    this.id,
    required this.text,
    required this.latitude,
    required this.longitude,
    required this.imagePath,
    required this.createdAt,
  });

  final int? id;
  final String text;
  final double latitude;
  final double longitude;
  final String? imagePath;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'text': text,
      'latitude': latitude,
      'longitude': longitude,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PlaceNote.fromMap(Map<String, Object?> map) {
    return PlaceNote(
      id: map['id'] as int?,
      text: map['text'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      imagePath: map['image_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
