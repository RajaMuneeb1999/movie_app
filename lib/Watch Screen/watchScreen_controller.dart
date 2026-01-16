import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Api_Call.dart';
import 'watchScreen_model.dart';

class WatchController extends GetxController {
  final TmdbService service;
  WatchController({required this.service});

  final movies = <Movie>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final error = ''.obs;

  int _page = 1;
  int _totalPages = 1;

  final ScrollController scrollController = ScrollController();

  final currentIndex = 1.obs;

  final isSearchMode = false.obs;
  final searchText = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocus = FocusNode();

  final topResults = <Movie>[].obs;
  final isSearching = false.obs;
  final searchError = ''.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchFirstPage();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 300 &&
          !isLoadingMore.value &&
          _page < _totalPages &&
          !isSearchMode.value) {
        fetchMore();
      }
    });
  }

  void changeTab(int i) {
    currentIndex.value = i;
  }

  void openSearch() {
    isSearchMode.value = true;

    Future.delayed(const Duration(milliseconds: 100), () {
      searchFocus.requestFocus();
    });
  }

  void closeSearch() {
    _debounce?.cancel();
    searchController.clear();
    searchText.value = '';
    topResults.clear();
    searchError.value = '';
    isSearching.value = false;

    isSearchMode.value = false;
    searchFocus.unfocus();
  }

  void onSearchChanged(String v) {
    searchText.value = v;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final q = v.trim();

      if (q.isEmpty) {
        topResults.clear();
        searchError.value = '';
        return;
      }

      await fetchTopResults(q);
    });
  }

  Future<void> fetchTopResults(String q) async {
    try {
      isSearching.value = true;
      searchError.value = '';

      final resp = await service.searchMovies(query: q, page: 1);

      topResults.assignAll(resp.results.take(10).toList());
    } catch (e) {
      searchError.value = e.toString();
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> fetchFirstPage() async {
    try {
      error.value = '';
      isLoading.value = true;
      _page = 1;

      final resp = await service.fetchUpcoming(page: _page);
      _totalPages = resp.totalPages;

      movies.assignAll(resp.results);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMore() async {
    try {
      isLoadingMore.value = true;
      final next = _page + 1;

      final resp = await service.fetchUpcoming(page: next);
      _page = resp.page;
      _totalPages = resp.totalPages;

      movies.addAll(resp.results);
    } catch (_) {
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> onRefresh() => fetchFirstPage();

  @override
  void onClose() {
    _debounce?.cancel();
    scrollController.dispose();
    searchController.dispose();
    searchFocus.dispose();
    super.onClose();
  }
}
