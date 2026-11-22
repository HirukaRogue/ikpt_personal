class Place {
  final String name;
  String assetPath; // Image for the gallery
  String videoPath; // Video for zen mode and asset_show
  final String country;
  final String description;

  Place({
    required this.name,
    this.assetPath = '',
    this.videoPath = '',
    required this.country,
    required this.description,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['placeName'] ?? '',
      assetPath: json['imagePath'] ?? '', // Map according to your JSON
      videoPath: json['videoPath'] ?? '', // Map according to your JSON
      country: json['countryBelonging'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
