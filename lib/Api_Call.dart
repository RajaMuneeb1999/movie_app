import 'dart:convert';
import 'package:http/http.dart' as http;

import 'Watch Screen/watchScreen_model.dart';

class TmdbService {
  static const String _baseUrl = "https://api.themoviedb.org/3";
  final String apiKey;

  TmdbService({required this.apiKey});

  Future<UpcomingResponse> fetchUpcoming({int page = 1}) async {
    final uri = Uri.parse(
      "$_baseUrl/movie/upcoming?api_key=$apiKey&language=en-US&page=$page",
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception("TMDB upcoming error ${res.statusCode}: ${res.body}");
    }

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    return UpcomingResponse.fromJson(jsonMap);
  }

  Future<UpcomingResponse> searchMovies({
    required String query,
    int page = 1,
  }) async {
    final q = query.trim();
    if (q.isEmpty) {
      return UpcomingResponse(page: 1, totalPages: 1, results: []);
    }

    final uri = Uri.parse(
      "$_baseUrl/search/movie?api_key=$apiKey"
      "&language=en-US"
      "&query=${Uri.encodeQueryComponent(q)}"
      "&page=$page"
      "&include_adult=false",
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception("TMDB search error ${res.statusCode}: ${res.body}");
    }

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    return UpcomingResponse.fromJson(jsonMap);
  }

  Future<Map<String, dynamic>> fetchMovieDetails(int movieId) async {
    final uri = Uri.parse(
      "$_baseUrl/movie/$movieId?api_key=$apiKey&language=en-US",
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception("TMDB details error ${res.statusCode}: ${res.body}");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchMovieVideos(int movieId) async {
    final uri = Uri.parse(
      "$_baseUrl/movie/$movieId/videos?api_key=$apiKey&language=en-US",
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception("TMDB videos error ${res.statusCode}: ${res.body}");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  String findYoutubeTrailerKey(Map<String, dynamic> videosJson) {
    final results = (videosJson['results'] as List? ?? []);

    for (final item in results) {
      final m = item as Map<String, dynamic>;
      final site = (m['site'] ?? '').toString();
      final type = (m['type'] ?? '').toString();
      if (site == 'YouTube' && type == 'Trailer') {
        return (m['key'] ?? '').toString();
      }
    }

    for (final item in results) {
      final m = item as Map<String, dynamic>;
      if ((m['site'] ?? '').toString() == 'YouTube') {
        return (m['key'] ?? '').toString();
      }
    }

    return '';
  }
}
