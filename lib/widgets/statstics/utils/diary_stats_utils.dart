// lib/utils/diary_stats_utils.dart
import '../../../const/diary_option.dart';
import '../../../model/diary_model.dart';

/// 최근 30일 vs 그 이전 30일 통계를 묶어주는 데이터 클래스
class ThirtyDayStats {
  final Map<String, double> current;
  final Map<String, double> previous;
  final Map<String, double> currentActivity;
  final Map<String, double> previousActivity;
  final Map<String, double> currentSocial;
  final Map<String, double> previousSocial;

  const ThirtyDayStats({
    required this.current,
    required this.previous,
    required this.currentActivity,
    required this.previousActivity,
    required this.currentSocial,
    required this.previousSocial,
  });
}

/// 다이어리 통계 계산 유틸
class DiaryStatsUtils {
  /// 월간 통계 계산 (건수, 증감, 증감 퍼센트)
  static Map<String, num> calculateMonthlyStats(List<DiaryModel> diaryList) {
    if (diaryList.isEmpty) {
      return {'current': 0, 'previous': 0, 'difference': 0, 'changePercent': 0};
    }

    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final previousMonth = DateTime(now.year, now.month - 1);

    final currentCount = diaryList
        .where(
          (d) =>
              d.date.year == currentMonth.year &&
              d.date.month == currentMonth.month,
        )
        .length;
    final previousCount = diaryList
        .where(
          (d) =>
              d.date.year == previousMonth.year &&
              d.date.month == previousMonth.month,
        )
        .length;

    final diff = currentCount - previousCount;
    final percent = previousCount > 0
        ? (diff / previousCount * 100).round()
        : 0;

    return {
      'current': currentCount,
      'previous': previousCount,
      'difference': diff,
      'changePercent': percent,
    };
  }

  /// 연속 작성 일수 계산 (날짜 중복 제거)
  static int calculateStreakDays(List<DiaryModel> diaryList) {
    if (diaryList.isEmpty) return 0;

    final dates =
        diaryList
            .map((d) => DateTime(d.date.year, d.date.month, d.date.day))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    int streak = 1;
    var last = dates.first;

    for (var i = 1; i < dates.length; i++) {
      final diff = last.difference(dates[i]).inDays;
      if (diff == 1) {
        streak++;
        last = dates[i];
      } else {
        break;
      }
    }
    return streak;
  }

  /// 평균 단어 수 계산
  static int calculateAverageWordCount(List<DiaryModel> diaryList) {
    if (diaryList.isEmpty) return 0;

    final totalWords = diaryList.fold<int>(
      0,
      (sum, d) => sum + d.content.trim().split(RegExp(r'\s+')).length,
    );
    return (totalWords / diaryList.length).round();
  }

  /// 가장 많이 작성하는 시간대 계산
  static int calculateMostCommonHour(List<DiaryModel> diaryList) {
    if (diaryList.isEmpty) return 21;
    final Map<int, int> cnt = {};
    for (var d in diaryList) {
      cnt[d.createdAt.hour] = (cnt[d.createdAt.hour] ?? 0) + 1;
    }
    return cnt.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// 시간 포맷팅 (12시간)
  static String formatHour(int hour) {
    if (hour == 0) return '오전 12시';
    if (hour < 12) return '오전 ${hour}시';
    if (hour == 12) return '오후 12시';
    return '오후 ${hour - 12}시';
  }

  /// 감정 통계 계산
  static Map<String, double> calculateEmotionStats(List<DiaryModel> diaryList) {
    return _calculateFieldStats(
      diaryList,
      DiaryConstants.emotionOrder,
      (d) => d.emotion,
    );
  }

  /// 날씨 통계 계산
  static Map<String, double> calculateWeatherStats(List<DiaryModel> diaryList) {
    return _calculateFieldStats(
      diaryList,
      DiaryConstants.weatherOrder,
      (d) => d.weather,
    );
  }

  /// 사회적 상황 통계 계산
  static Map<String, double> calculateSocialStats(List<DiaryModel> diaryList) {
    return _calculateFieldStats(
      diaryList,
      DiaryConstants.socialOrder,
      (d) => d.socialContext,
    );
  }

  /// 활동 유형 통계 계산
  static Map<String, double> calculateActivityStats(
    List<DiaryModel> diaryList,
  ) {
    return _calculateFieldStats(
      diaryList,
      DiaryConstants.activityOrder,
      (d) => d.activityType,
    );
  }

  /// 주간 패턴 계산 (1=월요일, 7=일요일)
  static Map<int, double> calculateWeeklyPattern(List<DiaryModel> diaryList) {
    final dayCount = {for (var i = 1; i <= 7; i++) i: 0};
    if (diaryList.isEmpty) {
      return {for (var i = 1; i <= 7; i++) i: 0.0};
    }
    for (var d in diaryList) {
      dayCount[d.date.weekday] = dayCount[d.date.weekday]! + 1;
    }
    var maxC = dayCount.values.reduce((a, b) => a > b ? a : b);
    if (maxC == 0) maxC = 1;
    return dayCount.map((k, v) => MapEntry(k, v / maxC));
  }

  /// 이번주 통계 계산 (최근 7일)
  static Map<String, double> calculateThisWeekSocialStats(
    List<DiaryModel> diaryList,
  ) {
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));

    final thisWeekDiaries = diaryList.where((d) {
      return d.createdAt.isAfter(weekAgo) &&
          d.createdAt.isBefore(now.add(Duration(days: 1)));
    }).toList();

    return _calculateFieldStats(
      thisWeekDiaries,
      DiaryConstants.socialOrder,
      (d) => d.socialContext,
    );
  }

  /// 저번주 통계 계산 (7-14일 전)
  static Map<String, double> calculateLastWeekSocialStats(
    List<DiaryModel> diaryList,
  ) {
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));
    final twoWeeksAgo = now.subtract(Duration(days: 14));

    final lastWeekDiaries = diaryList.where((d) {
      return d.createdAt.isAfter(twoWeeksAgo) &&
          d.createdAt.isBefore(weekAgo.add(Duration(days: 1)));
    }).toList();

    return _calculateFieldStats(
      lastWeekDiaries,
      DiaryConstants.socialOrder,
      (d) => d.socialContext,
    );
  }

  /// 최근 30일 vs 그 이전 30일 통계 묶음
  static ThirtyDayStats compute30DayStats(List<DiaryModel> diaryList) {
    final now = DateTime.now();
    final startCurrent = now.subtract(Duration(days: 30));
    final startPrevious = now.subtract(Duration(days: 60));

    final currentSlice = diaryList
        .where(
          (d) =>
              d.date.isAfter(startCurrent) &&
              d.date.isBefore(now.add(Duration(days: 1))),
        )
        .toList();
    final previousSlice = diaryList
        .where(
          (d) => d.date.isAfter(startPrevious) && d.date.isBefore(startCurrent),
        )
        .toList();

    return ThirtyDayStats(
      current: _calculateFieldStats(
        currentSlice,
        DiaryConstants.emotionOrder,
        (d) => d.emotion,
      ),
      previous: _calculateFieldStats(
        previousSlice,
        DiaryConstants.emotionOrder,
        (d) => d.emotion,
      ),
      currentActivity: _calculateFieldStats(
        currentSlice,
        DiaryConstants.activityOrder,
        (d) => d.activityType,
      ),
      previousActivity: _calculateFieldStats(
        previousSlice,
        DiaryConstants.activityOrder,
        (d) => d.activityType,
      ),
      currentSocial: _calculateFieldStats(
        currentSlice,
        DiaryConstants.socialOrder,
        (d) => d.socialContext,
      ),
      previousSocial: _calculateFieldStats(
        previousSlice,
        DiaryConstants.socialOrder,
        (d) => d.socialContext,
      ),
    );
  }

  /// 공통 필드 통계 계산 (단일 선택용)
  static Map<String, double> _calculateFieldStats(
    List<DiaryModel> diaryList,
    List<String> order,
    String Function(DiaryModel) fieldGetter,
  ) {
    if (diaryList.isEmpty) {
      return {for (var e in order) e: 0.0};
    }
    final Map<String, int> cnt = {for (var e in order) e: 0};
    for (var d in diaryList) {
      final fieldValue = fieldGetter(d);
      if (cnt.containsKey(fieldValue)) {
        cnt[fieldValue] = cnt[fieldValue]! + 1;
      }
    }
    final total = diaryList.length;
    return cnt.map((k, v) => MapEntry(k, v / total));
  }

  /// 모든 통계 요약
  static DiaryStatsSummary calculateAllStats(List<DiaryModel> diaryList) {
    return DiaryStatsSummary(
      monthlyStats: calculateMonthlyStats(diaryList),
      streakDays: calculateStreakDays(diaryList),
      totalDiaries: diaryList.length,
      averageWordCount: calculateAverageWordCount(diaryList),
      mostCommonHour: calculateMostCommonHour(diaryList),
      emotionStats: calculateEmotionStats(diaryList),
      weatherStats: calculateWeatherStats(diaryList),
      socialStats: calculateSocialStats(diaryList),
      activityStats: calculateActivityStats(diaryList),
      weeklyPattern: calculateWeeklyPattern(diaryList),
      thisWeekSocialStats: calculateThisWeekSocialStats(diaryList),
      lastWeekSocialStats: calculateLastWeekSocialStats(diaryList),
    );
  }
}

/// 통계 요약 데이터 클래스
class DiaryStatsSummary {
  final Map<String, num> monthlyStats;
  final int streakDays;
  final int totalDiaries;
  final int averageWordCount;
  final int mostCommonHour;
  final Map<String, double> emotionStats;
  final Map<String, double> weatherStats;
  final Map<String, double> socialStats;
  final Map<String, double> activityStats;
  final Map<int, double> weeklyPattern;
  final Map<String, double> thisWeekSocialStats;
  final Map<String, double> lastWeekSocialStats;

  const DiaryStatsSummary({
    required this.monthlyStats,
    required this.streakDays,
    required this.totalDiaries,
    required this.averageWordCount,
    required this.mostCommonHour,
    required this.emotionStats,
    required this.weatherStats,
    required this.socialStats,
    required this.activityStats,
    required this.weeklyPattern,
    required this.thisWeekSocialStats,
    required this.lastWeekSocialStats,
  });

  int get currentMonthCount => (monthlyStats['current'] ?? 0).toInt();
  int get monthDifference => (monthlyStats['difference'] ?? 0).toInt();
  int get monthChangePercent => (monthlyStats['changePercent'] ?? 0).toInt();
}
