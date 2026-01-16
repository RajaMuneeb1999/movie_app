class UpcomingResponse {
  final int page;
  final int totalPages;
  final List<Movie> results;

  UpcomingResponse({
    required this.page,
    required this.totalPages,
    required this.results,
  });

  factory UpcomingResponse.fromJson(Map<String, dynamic> json) {
    return UpcomingResponse(
      page: json['page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      results: (json['results'] as List? ?? [])
          .map((e) => Movie.fromJson(e))
          .toList(),
    );
  }
}

class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'],
    );
  }

  String? get backdropUrl => backdropPath == null
      ? null
      : "https://image.tmdb.org/t/p/w780$backdropPath";

  String? get posterUrl =>
      posterPath == null ? null : "https://image.tmdb.org/t/p/w500$posterPath";
}
