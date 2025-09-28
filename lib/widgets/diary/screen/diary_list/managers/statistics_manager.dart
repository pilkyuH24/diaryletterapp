import 'package:diaryletter/widgets/diary/services/diary_service.dart';
import 'package:flutter/material.dart';

class StatisticsManager {
  final Function(int) onDiaryCountUpdate;
  final Function(Map<String, int>) onEmotionStatsUpdate;

  StatisticsManager({
    required this.onDiaryCountUpdate,
    required this.onEmotionStatsUpdate,
  });

  /// 일기 개수 로드
  Future<void> loadDiaryCount() async {
    try {
      final count = await DiaryService.getDiaryCount();
      onDiaryCountUpdate(count);
    } catch (e) {
      debugPrint('❌ [Statistics Manager] 일기 개수 로드 실패: $e');
    }
  }

  /// 모든 통계 로드
  Future<void> loadStatistics() async {
    try {
      final emotionStats = await DiaryService.getEmotionStatistics();
      onEmotionStatsUpdate(emotionStats);
    } catch (e) {
      debugPrint('❌ [Statistics Manager] 통계 로드 실패: $e');
    }
  }

  /// 모든 통계 새로고침
  Future<void> refreshAll() async {
    await Future.wait([loadDiaryCount(), loadStatistics()]);
  }
}
