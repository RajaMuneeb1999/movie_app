class MovieDetail {
  final int id;
  final String title;
  final String? overview;
  final String? backdropPath;
  final String? posterPath;
  final String? releaseDate;
  final List<String> genres;

  MovieDetail({
    required this.id,
    required this.title,
    this.overview,
    this.backdropPath,
    this.posterPath,
    this.releaseDate,
    required this.genres,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    final genresJson = (json['genres'] as List? ?? []);
    return MovieDetail(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'],
      backdropPath: json['backdrop_path'],
      posterPath: json['poster_path'],
      releaseDate: json['release_date'],
      genres: genresJson
          .map((e) => (e as Map<String, dynamic>)['name']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList(),
    );
  }

  String? get backdropUrl => backdropPath == null
      ? null
      : "https://image.tmdb.org/t/p/w780$backdropPath";
  String? get posterUrl =>
      posterPath == null ? null : "https://image.tmdb.org/t/p/w500$posterPath";
}
