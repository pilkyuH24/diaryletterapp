// lib/screens/diary_list_screen.dart

import 'package:diaryletter/model/diary_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/model/diary_model.dart';
import 'package:diaryletter/widgets/diary/screen/diary_read/diary_read_screen.dart';
import 'package:diaryletter/widgets/diary/screen/diary_write/diary_write_screen.dart';
import 'package:diaryletter/widgets/diary/services/diary_service.dart';

// 모듈화된 컴포넌트들 import
import 'package:diaryletter/widgets/diary/screen/diary_list/components/diary_list_item.dart';
import 'package:diaryletter/widgets/diary/screen/diary_list/components/empty_diary_view.dart';
import 'package:diaryletter/widgets/diary/screen/diary_list/components/diary_search_filter.dart';
import 'package:diaryletter/widgets/diary/screen/diary_list/components/diary_list_app_bar.dart';
import 'package:diaryletter/widgets/diary/screen/diary_list/components/filter_chip_widget.dart';
import 'package:diaryletter/widgets/diary/screen/diary_list/components/loading_indicators.dart';
import 'package:diaryletter/widgets/diary/screen/diary_list/components/error_state_widget.dart';
import 'package:diaryletter/widgets/diary/screen/diary_list/components/empty_search_result.dart';
import 'package:diaryletter/widgets/diary/screen/diary_list/managers/search_manager.dart';
import 'package:diaryletter/widgets/diary/screen/diary_list/managers/statistics_manager.dart';

class DiaryListScreen extends StatefulWidget {
  final ValueNotifier<bool>? refreshNotifier;

  const DiaryListScreen({Key? key, this.refreshNotifier}) : super(key: key);

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  // Controllers
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Managers
  late SearchManager _searchManager;
  late StatisticsManager _statisticsManager;

  // State variables
  List<DiaryModel> diaries = [];
  bool isLoading = false;
  bool hasMore = true;
  int currentPage = 0;
  String? errorMessage;
  int totalDiaryCount = 0;
  bool isSearchMode = false;
  DiaryFilter currentFilter = DiaryFilter.empty;
  Map<String, int> emotionStats = {};

  @override
  void initState() {
    super.initState();
    _initializeManagers();
    _loadInitialData();
    _scrollController.addListener(_onScroll);

    widget.refreshNotifier?.addListener(_refreshAll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    widget.refreshNotifier?.removeListener(_refreshAll);
    super.dispose();
  }

  void _initializeManagers() {
    _searchManager = SearchManager(
      onResultsUpdate: (results) => _updateDiaryList(results),
      onLoadingUpdate: (loading) => _updateLoadingState(loading),
      onErrorUpdate: (error) => _showErrorSnackBar(error),
    );

    _statisticsManager = StatisticsManager(
      onDiaryCountUpdate: (count) => _updateDiaryCount(count),
      onEmotionStatsUpdate: (stats) => _updateEmotionStats(stats),
    );
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadDiaries(),
      _statisticsManager.loadDiaryCount(),
      _statisticsManager.loadStatistics(),
    ]);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoading &&
        hasMore &&
        !isSearchMode &&
        !currentFilter.hasFilter) {
      _loadMoreDiaries();
    }
  }

  void _updateDiaryList(List<DiaryModel> newDiaries) {
    if (mounted) {
      setState(() {
        diaries = newDiaries;
      });
      _keepSearchFocus();
    }
  }

  void _updateLoadingState(bool loading) {
    if (mounted) setState(() => isLoading = loading);
  }

  void _updateDiaryCount(int count) {
    if (mounted) setState(() => totalDiaryCount = count);
  }

  void _updateEmotionStats(Map<String, int> stats) {
    if (mounted) setState(() => emotionStats = stats);
  }

  Future<void> _loadDiaries() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
      isSearchMode = false;
      currentFilter = DiaryFilter.empty;
    });
    try {
      final result = await DiaryService.loadDiaries(0);
      if (mounted) {
        setState(() {
          diaries = result.diaries;
          currentPage = 0;
          hasMore = result.hasMore;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = '일기를 불러오는데 실패했습니다';
        });
        _showErrorSnackBar('일기를 불러오는데 실패했습니다');
      }
    }
  }

  Future<void> _loadMoreDiaries() async {
    if (isLoading || !hasMore || isSearchMode || currentFilter.hasFilter)
      return;
    setState(() => isLoading = true);
    try {
      final nextPage = currentPage + 1;
      final result = await DiaryService.loadDiaries(nextPage);
      if (mounted) {
        setState(() {
          diaries.addAll(result.diaries);
          currentPage = nextPage;
          hasMore = result.hasMore;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showErrorSnackBar('추가 일기를 불러오는데 실패했습니다');
      }
    }
  }

  void _enterSearchMode() {
    setState(() => isSearchMode = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  void _onSearchTextChanged(String keyword) {
    // 실시간 검색은 사용하지 않음
  }

  void _onSearchSubmitted(String keyword) {
    if (keyword.trim().isEmpty) {
      _clearSearchAndFilter();
      return;
    }
    if (!isSearchMode) {
      setState(() {
        isSearchMode = true;
        hasMore = false;
      });
    }
    _searchManager.searchDiaries(keyword);
  }

  void _clearSearchAndFilter() {
    _searchController.clear();
    setState(() {
      currentFilter = DiaryFilter.empty;
      isSearchMode = false;
    });
    _loadDiaries();
  }

  void _keepSearchFocus() {
    if (isSearchMode && !_searchFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }
  }

  // 기존 바텀시트 코드 대신
  Future<void> _showFilterDialog() async {
    final result = await showFilterScreen(context, currentFilter, emotionStats);

    if (result != null) {
      if (result == DiaryFilter.empty) {
        _clearSearchAndFilter();
      } else {
        setState(() {
          currentFilter = result;
          hasMore = false;
          isSearchMode = true;
        });
        await _searchManager.applyFilter(result);
      }
    }
  }

  /// 일기 읽기 화면으로 이동
  void _onDiaryTap(DiaryModel diary) async {
    // await SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    // ]);

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => DiaryReadScreen(diary: diary)),
    );

    // await SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    // ]);

    if (result?['refresh'] == true) {
      await _refreshAll();
      // _showSuccessSnackBar('일기가 삭제/수정되었습니다');
      widget.refreshNotifier?.value = !widget.refreshNotifier!.value;
    }
  }

  /// 일기 작성 화면으로 이동
  void _onWriteDiary() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => DiaryWriteScreen(selectedDate: DateTime.now()),
      ),
    );
    if (result?['refresh'] == true) {
      await _refreshAll();
      // _showSuccessSnackBar('새 일기가 저장되었습니다');
      widget.refreshNotifier?.value = !widget.refreshNotifier!.value;
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([_loadDiaries(), _statisticsManager.refreshAll()]);
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final fontProvider = context.watch<FontProvider>();
    final tc = themeProv.colors;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: DiaryListAppBar(
        isSearchMode: isSearchMode,
        hasFilter: currentFilter.hasFilter,
        totalDiaryCount: totalDiaryCount,
        searchController: _searchController,
        searchFocusNode: _searchFocusNode,
        onSearchSubmitted: _onSearchSubmitted,
        onSearchChanged: _onSearchTextChanged,
        onSearchTap: _enterSearchMode,
        onClearTap: _clearSearchAndFilter,
        onFilterTap: _showFilterDialog,
        themeColors: tc,
        fontProvider: fontProvider,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [tc.surface, tc.surface, tc.accent.withOpacity(0.8)],
          ),
        ),
        child: Column(
          children: [
            if (currentFilter.hasFilter)
              FilterChipWidget(
                currentFilter: currentFilter,
                onClear: _clearSearchAndFilter,
                themeColors: tc,
                fontProvider: fontProvider,
              ),
            Expanded(
              child: RefreshIndicator(
                backgroundColor: tc.background,
                color: tc.primary,
                onRefresh: _refreshAll,
                child: _buildBody(tc, fontProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(tc, FontProvider fontProvider) {
    if (fontProvider.fontFamily == '' && fontProvider.fontSize == 0) {
      return LoadingIndicators.center(tc, '설정을 불러오는 중...');
    }
    if (diaries.isEmpty && isLoading && errorMessage == null) {
      String msg = isSearchMode
          ? '검색 중...'
          : currentFilter.hasFilter
          ? '필터링 중...'
          : '일기를 불러오는 중...';
      return LoadingIndicators.center(tc, msg);
    }
    if (diaries.isEmpty && !isLoading && errorMessage != null) {
      return ErrorStateWidget(
        errorMessage: errorMessage!,
        onRetry: _loadDiaries,
        themeColors: tc,
        fontProvider: fontProvider,
      );
    }
    if (diaries.isEmpty && !isLoading) {
      return isSearchMode || currentFilter.hasFilter
          ? EmptySearchResult(
              isFilterMode: currentFilter.hasFilter,
              currentFilter: currentFilter,
              themeColors: tc,
              fontProvider: fontProvider,
            )
          : EmptyDiaryView(
              onWriteDiary: _onWriteDiary,
              accentColor: tc.accent,
              textColor: tc.textPrimary,
            );
    }
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount:
          diaries.length +
          (hasMore && isLoading && !isSearchMode && !currentFilter.hasFilter
              ? 1
              : 0),
      itemBuilder: (context, index) {
        if (index == diaries.length) {
          return LoadingIndicators.bottom(tc);
        }
        return DiaryListItem(
          diary: diaries[index],
          index: index,
          fontProvider: fontProvider,
          themeColors: tc,
          onTap: () => _onDiaryTap(diaries[index]),
        );
      },
    );
  }
}
