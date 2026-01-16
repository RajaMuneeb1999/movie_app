import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../Api_Call.dart';
import 'Watch Screen/watchScreen_model.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;
  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final TmdbService service;
  bool loading = true;
  String err = '';
  List<Movie> results = [];

  @override
  void initState() {
    super.initState();
    service = Get.find<TmdbService>();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        loading = true;
        err = '';
      });
      final resp = await service.searchMovies(query: widget.query, page: 1);
      setState(() => results = resp.results);
    } catch (e) {
      setState(() => err = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text("${results.length} Results Found"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : err.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(err),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final m = results[i];
                final img = m.posterUrl ?? m.backdropUrl;

                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 120,
                        height: 72,
                        child: img == null
                            ? Container(color: Colors.black12)
                            : CachedNetworkImage(
                                imageUrl: img,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m.releaseDate ?? "",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_horiz),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
