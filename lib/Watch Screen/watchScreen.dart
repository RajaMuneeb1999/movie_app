import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../Api_Call.dart';
import '../Movie Detail/movie_detail_screen.dart';
import '../search_results_screen.dart';
import 'watchScreen_controller.dart';
import 'watchScreen_model.dart';

class WatchScreen extends StatelessWidget {
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TmdbService>()) {
      Get.put(
        TmdbService(apiKey: "7e12370980318c50f63e10b668348a8d"),
        permanent: true,
      );
    }

    final WatchController controller = Get.put(
      WatchController(service: Get.find<TmdbService>()),
      permanent: true,
    );

    return Obx(() {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: controller.isSearchMode.value
              ? _SearchAppBar(controller: controller)
              : AppBar(
                  title: const Text("Watch"),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: controller.openSearch,
                    ),
                  ],
                ),
        ),

        body: controller.isSearchMode.value
            ? _SearchTopResults(controller: controller)
            : Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.error.value.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.error.value,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: controller.fetchFirstPage,
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.onRefresh,
                  child: ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    itemCount: controller.movies.length + 1,
                    itemBuilder: (context, index) {
                      if (index == controller.movies.length) {
                        return Obx(
                          () => controller.isLoadingMore.value
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : const SizedBox(height: 12),
                        );
                      }

                      final movie = controller.movies[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _MovieCard(movie: movie),
                      );
                    },
                  ),
                );
              }),

        bottomNavigationBar: Obx(() {
          return Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              backgroundColor: const Color.fromRGBO(46, 39, 57, 1),
              selectedItemColor: Colors.white,
              unselectedItemColor: const Color.fromARGB(136, 104, 100, 100),
              currentIndex: controller.currentIndex.value,
              type: BottomNavigationBarType.fixed,
              showUnselectedLabels: true,
              onTap: controller.changeTab,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  label: "Dashboard",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.play_circle_outline),
                  label: "Watch",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.video_library_outlined),
                  label: "Media Library",
                ),
                BottomNavigationBarItem(icon: Icon(Icons.menu), label: "More"),
              ],
            ),
          );
        }),
      );
    });
  }
}

class _SearchAppBar extends StatelessWidget {
  final WatchController controller;
  const _SearchAppBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Container(
        height: 42,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            const Icon(Icons.search),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller.searchController,
                focusNode: controller.searchFocus,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: "TV shows, movies and more",
                  border: InputBorder.none,
                ),
                onChanged: controller.onSearchChanged,
                onSubmitted: (v) {
                  final q = v.trim();
                  if (q.isNotEmpty) {
                    Get.to(() => SearchResultsScreen(query: q));
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: controller.closeSearch,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchTopResults extends StatelessWidget {
  final WatchController controller;
  const _SearchTopResults({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final q = controller.searchText.value.trim();

      if (q.isEmpty) {
        return const _GenreGrid();
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Top Results",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () => Get.to(() => SearchResultsScreen(query: q)),
                  child: const Text("See all"),
                ),
              ],
            ),

            if (controller.isSearching.value)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (controller.searchError.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(controller.searchError.value),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: controller.topResults.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final m = controller.topResults[i];
                    return _SearchRowTile(
                      movie: m,

                      onTap: () =>
                          Get.to(() => MovieDetailScreen(movieId: m.id)),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _SearchRowTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  const _SearchRowTile({required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final img = movie.posterUrl ?? movie.backdropUrl;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 120,
              height: 72,
              child: img == null
                  ? Container(color: Colors.black12)
                  : CachedNetworkImage(imageUrl: img, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  movie.releaseDate ?? "",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
        ],
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final Movie movie;
  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    final img = movie.backdropUrl ?? movie.posterUrl;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Get.to(() => MovieDetailScreen(movieId: movie.id)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: img == null
                  ? Container(color: Colors.black12)
                  : CachedNetworkImage(
                      imageUrl: img,
                      fit: BoxFit.cover,
                      placeholder: (c, _) => Container(color: Colors.black12),
                      errorWidget: (c, _, __) =>
                          Container(color: Colors.black12),
                    ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withOpacity(0.75),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Text(
                movie.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenreGrid extends StatelessWidget {
  const _GenreGrid();

  @override
  Widget build(BuildContext context) {
    final items = <_GenreItem>[
      _GenreItem(
        "Comedies",
        "https://images.unsplash.com/photo-1524253482453-3fed8d2fe12b?w=800",
      ),
      _GenreItem(
        "Crime",
        "https://images.unsplash.com/photo-1526378722484-bd91ca387e72?w=800",
      ),
      _GenreItem(
        "Family",
        "https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800",
      ),
      _GenreItem(
        "Documentaries",
        "https://images.unsplash.com/photo-1485846234645-a62644f84728?w=800",
      ),
      _GenreItem(
        "Dramas",
        "https://images.unsplash.com/photo-1524712245354-2c4e5e7121c0?w=800",
      ),
      _GenreItem(
        "Fantasy",
        "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800",
      ),
      _GenreItem(
        "Holidays",
        "https://images.unsplash.com/photo-1512389098783-66b81f86e199?w=800",
      ),
      _GenreItem(
        "Horror",
        "https://images.unsplash.com/photo-1509248961158-e54f6934749c?w=800",
      ),
      _GenreItem(
        "Sci-Fi",
        "https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=800",
      ),
      _GenreItem(
        "Thriller",
        "https://images.unsplash.com/photo-1520975958225-8c9b36d07f20?w=800",
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: GridView.builder(
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.25,
        ),
        itemBuilder: (context, i) {
          final item = items[i];
          return ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (c, _) => Container(color: Colors.black12),
                    errorWidget: (c, _, __) => Container(color: Colors.black12),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.black.withOpacity(0.65),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GenreItem {
  final String title;
  final String imageUrl;
  _GenreItem(this.title, this.imageUrl);
}
