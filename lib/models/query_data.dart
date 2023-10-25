class QueryData {
  final String query;
  final int suggestionsMaxCount;
  final String language;
  final String regionKladrId;
  final String countryIsoCode;

  QueryData({
    required this.query,
    this.regionKladrId = '',
    this.suggestionsMaxCount = 5,
    this.language = 'ru',
    this.countryIsoCode = 'RU',
  });

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'language': language,
      'count': suggestionsMaxCount,
      'locations_boost': [
        {
          'country_iso_code': countryIsoCode,
          'kladr_id': regionKladrId,
        }
      ]
    };
  }
}
