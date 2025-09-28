// lib/model/diary_filter.dart

import 'package:diaryletter/const/diary_option.dart';
import 'package:diaryletter/model/diary_model.dart'; // 🔧 DiaryModel import 추가

/// 일기 필터 상태 모델
class DiaryFilter {
  final String? emotion;
  final String? socialContext;
  final String? activityType;
  final String? weather;
  final DateTime? startDate;
  final DateTime? endDate;

  // 🔧 새로운 필드들 추가
  final int? year;
  final int? month;
  final String?
  quickPeriod; // 'thisWeek', 'thisMonth', 'recent6Months', 'thisYear'

  const DiaryFilter({
    this.emotion,
    this.socialContext,
    this.activityType,
    this.weather,
    this.startDate,
    this.endDate,
    this.year,
    this.month,
    this.quickPeriod,
  });

  bool get hasFilter =>
      emotion != null ||
      socialContext != null ||
      activityType != null ||
      weather != null ||
      startDate != null ||
      endDate != null ||
      year != null ||
      month != null ||
      quickPeriod != null;

  /// 사용자에게 보여줄 필터 설명 텍스트
  String get description {
    final parts = <String>[];

    // 🔧 빠른 기간 선택이 있으면 우선 표시
    if (quickPeriod != null) {
      switch (quickPeriod) {
        case 'thisWeek':
          parts.add('이번 주');
          break;
        case 'thisMonth':
          parts.add('이번 달');
          break;
        case 'recent6Months':
          parts.add('최근 6개월');
          break;
        case 'thisYear':
          parts.add('올해');
          break;
      }
    } else if (year != null && month != null) {
      parts.add('${year}년 ${month}월');
    } else if (year != null) {
      parts.add('${year}년');
    } else if (month != null) {
      parts.add('${month}월');
    }

    if (emotion != null) {
      parts.add(DiaryConstants.getLabel('emotion', emotion!));
    }
    if (socialContext != null) {
      parts.add(
        DiaryConstants.getLabel('social', socialContext!, forTag: true),
      );
    }
    if (activityType != null) {
      parts.add(
        DiaryConstants.getLabel('activity', activityType!, forTag: true),
      );
    }
    if (weather != null) {
      parts.add(DiaryConstants.getLabel('weather', weather!));
    }
    if (startDate != null && endDate != null) {
      parts.add(
        '${startDate!.month}/${startDate!.day} ~ ${endDate!.month}/${endDate!.day}',
      );
    }

    return parts.join(' • ');
  }

  DiaryFilter copyWith({
    String? emotion,
    String? socialContext,
    String? activityType,
    String? weather,
    DateTime? startDate,
    DateTime? endDate,
    int? year,
    int? month,
    String? quickPeriod,
    bool clearEmotion = false,
    bool clearSocial = false,
    bool clearActivity = false,
    bool clearWeather = false,
    bool clearDates = false,
    bool clearYear = false,
    bool clearMonth = false,
    bool clearQuickPeriod = false,
  }) {
    return DiaryFilter(
      emotion: clearEmotion ? null : (emotion ?? this.emotion),
      socialContext: clearSocial ? null : (socialContext ?? this.socialContext),
      activityType: clearActivity ? null : (activityType ?? this.activityType),
      weather: clearWeather ? null : (weather ?? this.weather),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      year: clearYear ? null : (year ?? this.year),
      month: clearMonth ? null : (month ?? this.month),
      quickPeriod: clearQuickPeriod ? null : (quickPeriod ?? this.quickPeriod),
    );
  }

  /// 🔧 새로운 AND 조건 필터링 로직
  bool matches(DiaryModel diary) {
    // 기간 필터 먼저 체크
    if (!_matchesPeriod(diary)) return false;

    // 감정 필터
    if (emotion != null && diary.emotion != emotion) return false;

    // 사회적 상황 필터
    if (socialContext != null && diary.socialContext != socialContext)
      return false;

    // 활동 타입 필터
    if (activityType != null && diary.activityType != activityType)
      return false;

    // 날씨 필터
    if (weather != null && diary.weather != weather) return false;

    return true;
  }

  bool _matchesPeriod(DiaryModel diary) {
    final now = DateTime.now();
    final diaryDate = diary.date;

    // 빠른 기간 선택이 있는 경우
    if (quickPeriod != null) {
      switch (quickPeriod) {
        case 'thisWeek':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(Duration(days: 6));
          return _isDateInRange(diaryDate, startOfWeek, endOfWeek);

        case 'thisMonth':
          final startOfMonth = DateTime(now.year, now.month, 1);
          final endOfMonth = DateTime(now.year, now.month + 1, 0);
          return _isDateInRange(diaryDate, startOfMonth, endOfMonth);

        case 'recent6Months':
          final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);
          return diaryDate.isAfter(sixMonthsAgo.subtract(Duration(days: 1)));

        case 'thisYear':
          return diaryDate.year == now.year;
      }
    }

    // 년도/월 필터
    if (year != null && diaryDate.year != year) return false;
    if (month != null && diaryDate.month != month) return false;

    // 날짜 범위 필터
    if (startDate != null && diaryDate.isBefore(startDate!)) return false;
    if (endDate != null && diaryDate.isAfter(endDate!)) return false;

    return true;
  }

  bool _isDateInRange(DateTime date, DateTime start, DateTime end) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(start.year, start.month, start.day);
    final endOnly = DateTime(end.year, end.month, end.day);

    return !dateOnly.isBefore(startOnly) && !dateOnly.isAfter(endOnly);
  }

  /// 빈 필터 상수
  static const empty = DiaryFilter();
}
