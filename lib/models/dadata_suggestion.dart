class DadataSuggestion {
  final String displayName;
  final String country;
  final double lat;
  final double lon;

  DadataSuggestion(this.displayName, this.country, this.lat, this.lon);

  Map<String, dynamic> toJson() {
    return {
      'value': displayName,
      'country': country,
      'geo_lat': lat,
      'geo_lon': lon,
    };
  }

  static DadataSuggestion fromJson(Map<String, dynamic> json) {
    return DadataSuggestion(
      json['value'] as String,
      json['data']['country'] as String,
      double.parse(json['data']['geo_lat'] as String),
      double.parse(json['data']['geo_lon'] as String),
    );
  }
}
