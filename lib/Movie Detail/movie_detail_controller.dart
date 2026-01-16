import 'package:get/get.dart';
import '../Api_Call.dart';
import 'movie_detail_model.dart';

class MovieDetailController extends GetxController {
  final TmdbService service;
  final int movieId;

  MovieDetailController({required this.service, required this.movieId});

  final isLoading = true.obs;
  final error = ''.obs;

  final detail = Rxn<MovieDetail>();
  final trailerKey = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      error.value = '';

      final d = await service.fetchMovieDetails(movieId);
      detail.value = MovieDetail.fromJson(d);

      final v = await service.fetchMovieVideos(movieId);
      final results = (v['results'] as List? ?? []);

      String key = '';
      for (final item in results) {
        final m = item as Map<String, dynamic>;
        final site = (m['site'] ?? '').toString();
        final type = (m['type'] ?? '').toString();
        if (site == 'YouTube' && type == 'Trailer') {
          key = (m['key'] ?? '').toString();
          break;
        }
      }

      if (key.isEmpty) {
        for (final item in results) {
          final m = item as Map<String, dynamic>;
          if ((m['site'] ?? '').toString() == 'YouTube') {
            key = (m['key'] ?? '').toString();
            break;
          }
        }
      }

      trailerKey.value = key;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
