import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Api_Call.dart';
import 'movie_detail_controller.dart';

class MovieDetailScreen extends StatelessWidget {
  final int movieId;
  const MovieDetailScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    final service = Get.find<TmdbService>();

    final MovieDetailController c = Get.put(
      MovieDetailController(service: service, movieId: movieId),
    );

    return Obx(() {
      if (c.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      if (c.error.value.isNotEmpty || c.detail.value == null) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    c.error.value.isEmpty ? "Failed to load" : c.error.value,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: c.load, child: const Text("Retry")),
                ],
              ),
            ),
          ),
        );
      }

      final d = c.detail.value!;
      final bg = d.backdropUrl ?? d.posterUrl;

      return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              width: double.infinity,
              child: bg == null
                  ? Container(color: Colors.black12)
                  : CachedNetworkImage(
                      imageUrl: bg,
                      fit: BoxFit.cover,
                      placeholder: (c, _) => Container(color: Colors.black12),
                      errorWidget: (c, _, __) =>
                          Container(color: Colors.black12),
                    ),
            ),

            Container(
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.65),
                  ],
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "Watch",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              top: MediaQuery.of(context).size.height * 0.28,
              child: Column(
                children: [
                  Text(
                    d.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    d.releaseDate == null || d.releaseDate!.isEmpty
                        ? ""
                        : "In Theaters ${_prettyDate(d.releaseDate!)}",
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF59C4F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Get Tickets",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.65)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: c.trailerKey.value.isEmpty
                          ? null
                          : () async {
                              final url = Uri.parse(
                                "https://www.youtube.com/watch?v=${c.trailerKey.value}",
                              );
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("Watch Trailer"),
                    ),
                  ),
                ],
              ),
            ),

            DraggableScrollableSheet(
              initialChildSize: 0.42,
              minChildSize: 0.38,
              maxChildSize: 0.85,
              builder: (context, scroll) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: ListView(
                    controller: scroll,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      const Text(
                        "Genres",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: d.genres
                            .map((g) => _GenreChip(text: g))
                            .toList(),
                      ),

                      const SizedBox(height: 18),
                      const Text(
                        "Overview",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        d.overview ?? "",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  static String _prettyDate(String yyyyMmDd) {
    final parts = yyyyMmDd.split('-');
    if (parts.length != 3) return yyyyMmDd;
    final y = parts[0];
    final m = int.tryParse(parts[1]) ?? 1;
    final d = int.tryParse(parts[2]) ?? 1;
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return "${months[m - 1]} $d, $y";
  }
}

class _GenreChip extends StatelessWidget {
  final String text;
  const _GenreChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
