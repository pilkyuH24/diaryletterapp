import 'dart:async';
import 'package:diaryletter/model/diary_filter.dart';
import 'package:flutter/material.dart';
import 'package:diaryletter/model/diary_model.dart';
import 'package:diaryletter/widgets/diary/services/diary_service.dart';

class SearchManager {
  final Function(List<DiaryModel>) onResultsUpdate;
  final Function(bool) onLoadingUpdate;
  final Function(String) onErrorUpdate;

  SearchManager({
    required this.onResultsUpdate,
    required this.onLoadingUpdate,
    required this.onErrorUpdate,
  });

  /// 일기 검색 (기존 메서드 유지)
  Future<void> searchDiaries(String keyword) async {
    if (keyword.trim().isEmpty) {
      return;
    }

    onLoadingUpdate(true);

    try {
      debugPrint('🔍 [Search Manager] 검색 시작: "$keyword"');

      final searchResults = await DiaryService.searchDiaries(
        keyword,
        limit: 50,
      );

      onResultsUpdate(searchResults);
      onLoadingUpdate(false);

      debugPrint('✅ [Search Manager] 검색 완료: ${searchResults.length}개 결과');
    } catch (e) {
      debugPrint('❌ [Search Manager] 검색 실패: $e');
      onLoadingUpdate(false);
      onErrorUpdate('검색 중 오류가 발생했습니다');
    }
  }

  /// 🔧 향상된 필터 적용 (AND 조건 지원)
  Future<void> applyFilter(DiaryFilter filter) async {
    onLoadingUpdate(true);

    try {
      debugPrint('🔍 [Search Manager] 복합 필터 적용 시작');
      debugPrint('   - 필터 조건: ${filter.description}');

      List<DiaryModel> filteredDiaries = [];

      // 🔧 새로운 복합 필터링 사용 (AND 조건)
      if (filter.hasFilter) {
        filteredDiaries = await DiaryService.getDiariesWithFilter(filter);
      } else {
        // 필터가 없으면 전체 조회
        final result = await DiaryService.loadDiaries(0);
        filteredDiaries = result.diaries;
      }

      onResultsUpdate(filteredDiaries);
      onLoadingUpdate(false);

      debugPrint('✅ [Search Manager] 필터 적용 완료: ${filteredDiaries.length}개 결과');
    } catch (e) {
      debugPrint('❌ [Search Manager] 필터 적용 실패: $e');
      onLoadingUpdate(false);
      onErrorUpdate('필터 적용 중 오류가 발생했습니다');

      // 🔧 fallback: 기존 OR 로직 사용
      await _applyFilterFallback(filter);
    }
  }

  /// 🔧 Fallback: 기존 OR 로직 (호환성 보장)
  Future<void> _applyFilterFallback(DiaryFilter filter) async {
    try {
      debugPrint('🔄 [Search Manager] Fallback 필터 적용');

      List<DiaryModel> filteredDiaries = [];

      if (filter.emotion != null) {
        filteredDiaries = await DiaryService.getDiariesByEmotion(
          filter.emotion!,
          limit: 100,
        );
      } else if (filter.socialContext != null) {
        filteredDiaries = await DiaryService.getDiariesBySocialContext(
          filter.socialContext!,
          limit: 100,
        );
      } else if (filter.activityType != null) {
        filteredDiaries = await DiaryService.getDiariesByActivity(
          filter.activityType!,
          limit: 100,
        );
      } else if (filter.weather != null) {
        filteredDiaries = await DiaryService.getDiariesByWeather(
          filter.weather!,
          limit: 100,
        );
      } else if (filter.startDate != null && filter.endDate != null) {
        filteredDiaries = await DiaryService.getDiariesByPeriod(
          filter.startDate!,
          filter.endDate!,
        );
      }

      onResultsUpdate(filteredDiaries);
      debugPrint(
        '✅ [Search Manager] Fallback 필터 적용 완료: ${filteredDiaries.length}개 결과',
      );
    } catch (e) {
      debugPrint('❌ [Search Manager] Fallback 필터 적용도 실패: $e');
      onErrorUpdate('필터 적용 중 오류가 발생했습니다');
    }
  }

  /// 🔧 새로운 메서드: 필터링된 통계 조회
  Future<FilteredStatistics> getFilteredStatistics(DiaryFilter filter) async {
    try {
      debugPrint('📊 [Search Manager] 필터링된 통계 조회 시작');

      final stats = await DiaryService.getFilteredStatistics(filter);

      debugPrint('✅ [Search Manager] 필터링된 통계 조회 완료');
      return stats;
    } catch (e) {
      debugPrint('❌ [Search Manager] 필터링된 통계 조회 실패: $e');
      return FilteredStatistics.empty();
    }
  }

  /// 🔧 기간별 검색 (기존 메서드 유지 - 호환성)
  Future<void> searchByPeriod(DateTime startDate, DateTime endDate) async {
    final filter = DiaryFilter(startDate: startDate, endDate: endDate);
    await applyFilter(filter);
  }

  /// 🔧 감정별 검색 (기존 메서드 유지 - 호환성)
  Future<void> searchByEmotion(String emotion) async {
    final filter = DiaryFilter(emotion: emotion);
    await applyFilter(filter);
  }

  /// 🔧 사회적 상황별 검색 (기존 메서드 유지 - 호환성)
  Future<void> searchBySocialContext(String socialContext) async {
    final filter = DiaryFilter(socialContext: socialContext);
    await applyFilter(filter);
  }

  /// 🔧 활동별 검색 (기존 메서드 유지 - 호환성)
  Future<void> searchByActivity(String activityType) async {
    final filter = DiaryFilter(activityType: activityType);
    await applyFilter(filter);
  }

  /// 🔧 날씨별 검색 (기존 메서드 유지 - 호환성)
  Future<void> searchByWeather(String weather) async {
    final filter = DiaryFilter(weather: weather);
    await applyFilter(filter);
  }

  /// 검색 결과 초기화
  void clearResults() {
    debugPrint('🔄 [Search Manager] 검색 결과 초기화');
    onResultsUpdate([]);
  }
}

// 🔧 SearchManager에서 FilteredStatistics 클래스 정의 제거
// DiaryService의 FilteredStatistics를 사용하므로 중복 정의 불필요
