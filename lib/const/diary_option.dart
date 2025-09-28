// lib/const/diary_option.dart

import 'package:flutter/material.dart';

/// 옵션 데이터 클래스 (아이콘은 assets/icons/{category}/{value}.png 경로에서 로드)
class DiaryOption {
  final String value;
  final String text;

  const DiaryOption({required this.value, required this.text});
}

/// 다이어리 선택지 정의
class DiaryOptions {
  // 감정 옵션들 (단일 선택)
  static const List<DiaryOption> emotions = [
    DiaryOption(value: 'happy', text: '행복함'),
    DiaryOption(value: 'excited', text: '신남'),
    DiaryOption(value: 'sad', text: '우울함'),
    DiaryOption(value: 'lonely', text: '외로움'),

    DiaryOption(value: 'love', text: '설렘'),
    DiaryOption(value: 'bored', text: '지루함'),
    DiaryOption(value: 'proud', text: '뿌듯함'),
    DiaryOption(value: 'blank', text: '무심함'),

    DiaryOption(value: 'thinking', text: '고민중'),
    DiaryOption(value: 'tired', text: '지침'),
    DiaryOption(value: 'anxious', text: '불안함'),
    DiaryOption(value: 'angry', text: '화남'),
  ];

  // 날씨 옵션들 (단일 선택)
  static const List<DiaryOption> weathers = [
    DiaryOption(value: 'sunny', text: '맑음'),
    DiaryOption(value: 'cloudy', text: '흐림'),
    DiaryOption(value: 'rainy', text: '비'),
    DiaryOption(value: 'snowy', text: '눈'),
  ];

  // 함께한 사람 옵션들 (단일 선택)
  static const List<DiaryOption> socialContexts = [
    DiaryOption(value: 'alone', text: '혼자'),
    DiaryOption(value: 'coworkers', text: '동료들'),
    DiaryOption(value: 'family', text: '가족'),
    DiaryOption(value: 'friends', text: '친구들'),
    DiaryOption(value: 'lover', text: '연인'),
  ];

  // 활동 유형 옵션들 (단일 선택)
  static const List<DiaryOption> activityTypes = [
    DiaryOption(value: 'everyday', text: '일상'),
    DiaryOption(value: 'work', text: '일'),
    DiaryOption(value: 'meeting', text: '만남'),
    DiaryOption(value: 'rest', text: '휴식'),

    DiaryOption(value: 'foodie', text: '미식'),
    DiaryOption(value: 'shopping', text: '쇼핑'),
    DiaryOption(value: 'event', text: '이벤트'),
    DiaryOption(value: 'hobby', text: '취미'),

    DiaryOption(value: 'travel', text: '여행'),
    DiaryOption(value: 'leisure', text: '여가'),
    DiaryOption(value: 'exercise', text: '운동'),
    DiaryOption(value: 'study', text: '자기계발'),
  ];

  // 기본값들 (사용하지 않음 - 새 일기는 빈 값으로 시작)
  static const Map<String, String> defaults = {
    'emotion': '',
    'weather': '',
    'socialContext': '',
    'activityType': '',
  };
}

/// 사용자 선택 상태 보관
class DiarySelections {
  final String emotion;
  final String weather;
  final String socialContext;
  final String activityType;

  const DiarySelections({
    required this.emotion,
    required this.weather,
    required this.socialContext,
    required this.activityType,
  });

  bool get isComplete =>
      emotion.isNotEmpty &&
      weather.isNotEmpty &&
      socialContext.isNotEmpty &&
      activityType.isNotEmpty;

  /// 선택된 값 리스트 (아이콘 렌더링시 사용)
  List<String> get selectedValues => [
    emotion,
    weather,
    socialContext,
    activityType,
  ];

  DiarySelections copyWith({
    String? emotion,
    String? weather,
    String? socialContext,
    String? activityType,
  }) {
    return DiarySelections(
      emotion: emotion ?? this.emotion,
      weather: weather ?? this.weather,
      socialContext: socialContext ?? this.socialContext,
      activityType: activityType ?? this.activityType,
    );
  }
}

/// 다이어리 상수 및 매핑 정의
class DiaryConstants {
  // ==================== 텍스트 라벨 ====================
  static const Map<String, String> emotionLabels = {
    'happy': '행복함',
    'excited': '신남',
    'love': '설렘',
    'bored': '지루함',
    'thinking': '고민중',
    'tired': '지침',
    'sad': '우울함',
    'angry': '화남',
    'anxious': '불안함',
    'blank': '무심함',
    'lonely': '외로움',
    'proud': '뿌듯함',
  };

  static const Map<String, String> weatherLabels = {
    'sunny': '맑음',
    'cloudy': '흐림',
    'rainy': '비',
    'snowy': '눈',
  };

  static const Map<String, String> socialLabels = {
    'alone': '혼자',
    'family': '가족',
    'friends': '친구들',
    'lover': '연인',
    'coworkers': '동료들',
  };

  static const Map<String, String> activityLabels = {
    'work': '일',
    'leisure': '여가',
    'rest': '휴식',
    'exercise': '운동',
    'study': '자기계발',
    'travel': '여행',
    'meeting': '만남',
    'shopping': '쇼핑',
    'event': '이벤트',
    'hobby': '취미',
    'foodie': '미식',
    'everyday': '일상',
  };

  // ==================== 태그용 라벨 (with 조사) ====================
  static const Map<String, String> socialTagLabels = {
    'alone': '혼자',
    'family': '가족과',
    'friends': '친구들과',
    'lover': '연인과',
    'coworkers': '동료들과',
  };

  static const Map<String, String> activityTagLabels = {
    'work': '일/업무',
    'leisure': '여가',
    'rest': '휴식',
    'exercise': '운동',
    'study': '자기계발',
    'travel': '여행',
    'meeting': '만남',
    'shopping': '쇼핑',
    'event': '이벤트',
    'hobby': '취미',
    'foodie': '미식',
    'everyday': '일상',
  };

  // ==================== 이모지 매핑 ====================
  static const Map<String, String> weatherEmojis = {
    'sunny': '☀️',
    'cloudy': '☁️',
    'rainy': '🌧️',
    'snowy': '❄️',
  };

  // ==================== 아이콘 경로 매핑 ====================
  static const Map<String, String> emotionIcons = {
    'happy': 'assets/icons/emotion/happy.png',
    'excited': 'assets/icons/emotion/excited.png',
    'love': 'assets/icons/emotion/love.png',
    'bored': 'assets/icons/emotion/bored.png',
    'thinking': 'assets/icons/emotion/thinking.png',
    'tired': 'assets/icons/emotion/tired.png',
    'sad': 'assets/icons/emotion/sad.png',
    'angry': 'assets/icons/emotion/angry.png',
    'anxious': 'assets/icons/emotion/anxious.png',
    'blank': 'assets/icons/emotion/blank.png',
    'lonely': 'assets/icons/emotion/lonely.png',
    'proud': 'assets/icons/emotion/proud.png',
  };

  static const Map<String, String> weatherIcons = {
    'sunny': 'assets/icons/weather/sunny.png',
    'cloudy': 'assets/icons/weather/cloudy.png',
    'rainy': 'assets/icons/weather/rainy.png',
    'snowy': 'assets/icons/weather/snowy.png',
  };

  static const Map<String, String> socialIcons = {
    'alone': 'assets/icons/people/alone.png',
    'family': 'assets/icons/people/family.png',
    'friends': 'assets/icons/people/friends.png',
    'lover': 'assets/icons/people/lover.png',
    'coworkers': 'assets/icons/people/coworkers.png',
  };

  static const Map<String, String> activityIcons = {
    'work': 'assets/icons/activity/work.png',
    'leisure': 'assets/icons/activity/leisure.png',
    'rest': 'assets/icons/activity/rest.png',
    'exercise': 'assets/icons/activity/exercise.png',
    'study': 'assets/icons/activity/study.png',
    'travel': 'assets/icons/activity/travel.png',
    'meeting': 'assets/icons/activity/meeting.png',
    'shopping': 'assets/icons/activity/shopping.png',
    'event': 'assets/icons/activity/event.png',
    'hobby': 'assets/icons/activity/hobby.png',
    'foodie': 'assets/icons/activity/foodie.png',
    'everyday': 'assets/icons/activity/everyday.png',
  };

  // ==================== 컬러 매핑 ====================
  static const Map<String, Color> emotionColors = {
    'happy': Color(0xFFFFC1E3),
    'excited': Color(0xFFFFD180),
    'love': Color(0xFFB3E5FC),
    'bored': Color(0xFFE0E0E0),
    'thinking': Color(0xFFCE93D8),
    'tired': Color(0xFFBDBDBD),
    'sad': Color(0xFF90CAF9),
    'angry': Color(0xFFEF9A9A),
    'anxious': Color(0xFFFFCC80),
    'blank': Color(0xFFF5F5F5),
    'lonely': Color(0xFFB39DDB),
    'proud': Color(0xFFFFE082),
  };

  static const Map<String, Color> weatherColors = {
    'sunny': Color(0xFFFFD54F),
    'cloudy': Color(0xFFB0BEC5),
    'rainy': Color(0xFF81C784),
    'snowy': Color(0xFFE1F5FE),
  };

  static const Map<String, Color> socialColors = {
    'alone': Color(0xFFCE93D8),
    'family': Color(0xFFFFAB91),
    'friends': Color(0xFF80CBC4),
    'lover': Color(0xFFF48FB1),
    'coworkers': Color(0xFF81C784),
  };

  static const Map<String, Color> activityColors = {
    'work': Color(0xFF90CAF9),
    'leisure': Color(0xFFFFAB91),
    'rest': Color(0xFFC5E1A5),
    'exercise': Color(0xFFFFCC80),
    'study': Color(0xFFCE93D8),
    'travel': Color(0xFF80CBC4),
    'meeting': Color(0xFFF8BBD9),
    'shopping': Color(0xFFFFCCBC),
    'event': Color(0xFFD1C4E9),
    'hobby': Color(0xFFDCEDC8),
    'foodie': Color(0xFFFFE0B2),
    'everyday': Color(0xFFB0BEC5),
  };

  // ==================== 순서 정의 ====================
  static const List<String> emotionOrder = [
    'happy',
    'excited',
    'love',
    'bored',
    'thinking',
    'tired',
    'sad',
    'angry',
    'anxious',
    'blank',
    'lonely',
    'proud',
  ];

  static const List<String> weatherOrder = [
    'sunny',
    'cloudy',
    'rainy',
    'snowy',
  ];

  static const List<String> socialOrder = [
    'alone',
    'family',
    'friends',
    'lover',
    'coworkers',
  ];

  static const List<String> activityOrder = [
    'work',
    'leisure',
    'rest',
    'exercise',
    'study',
    'travel',
    'meeting',
    'shopping',
    'event',
    'hobby',
    'foodie',
    'everyday',
  ];

  // ==================== 유틸리티 메서드 ====================

  /// 카테고리별로 적절한 라벨 반환
  static String getLabel(String category, String value, {bool forTag = false}) {
    switch (category) {
      case 'emotion':
        return emotionLabels[value] ?? value;
      case 'weather':
        return weatherLabels[value] ?? value;
      case 'social':
        return forTag
            ? (socialTagLabels[value] ?? value)
            : (socialLabels[value] ?? value);
      case 'activity':
        return forTag
            ? (activityTagLabels[value] ?? value)
            : (activityLabels[value] ?? value);
      default:
        return value;
    }
  }

  /// 카테고리별로 적절한 아이콘 경로 반환
  static String? getIconPath(String category, String value) {
    switch (category) {
      case 'emotion':
        return emotionIcons[value];
      case 'weather':
        return weatherIcons[value];
      case 'social':
        return socialIcons[value];
      case 'activity':
        return activityIcons[value];
      default:
        return null;
    }
  }

  /// 카테고리별로 적절한 색상 반환
  static Color getColor(String category, String value) {
    switch (category) {
      case 'emotion':
        return emotionColors[value] ?? Colors.grey;
      case 'weather':
        return weatherColors[value] ?? Colors.grey;
      case 'social':
        return socialColors[value] ?? Colors.grey;
      case 'activity':
        return activityColors[value] ?? Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// 날씨 이모지 반환
  static String? getWeatherEmoji(String weather) {
    return weatherEmojis[weather];
  }

  /// 날씨 이모지 반환
  static String? getWeatherIcon(String weather) {
    return weatherIcons[weather];
  }

  /// 값으로부터 카테고리 추론
  static String getCategoryFromValue(String value) {
    if (emotionOrder.contains(value)) return 'emotion';
    if (weatherOrder.contains(value)) return 'weather';
    if (socialOrder.contains(value)) return 'social';
    if (activityOrder.contains(value)) return 'activity';
    return 'unknown';
  }
}
