class QueryData {
  final String query;

  QueryData(this.query);

  Map<String, dynamic> toJson(int count, String regionCode) {
    return {
      'query': query,
      'count': count,
      'locations_boost': [
        {'kladr_id': regionCode}
      ]
    };
  }
}
