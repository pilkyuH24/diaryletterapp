import 'package:flutter/material.dart';

class DiaryTagsRow extends StatelessWidget {
  final String weather;
  final String emotion;
  final String socialContext;
  final String activityType;

  const DiaryTagsRow({
    Key? key,
    required this.weather,
    required this.emotion,
    required this.socialContext,
    required this.activityType,
  }) : super(key: key);

  // ───── 날씨 이모지
  static const _weatherEmojiMap = {
    'sunny': '☀️',
    'cloudy': '☁️',
    'rainy': '🌧️',
    'snowy': '❄️',
  };

  // ───── 텍스트 라벨 (DiaryOptions에 맞게 업데이트)
  static const _emotionTextMap = {
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

  static const _socialTextMap = {
    'alone': '혼자',
    'family': '가족과',
    'friends': '친구들과',
    'lover': '연인과',
    'coworkers': '동료들과',
  };

  static const _activityTextMap = {
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

  // ───── 랜덤 컬러 (눈에 잘 띄는 색만)
  Color _randomColor(String key) {
    if (key.isEmpty) return Colors.grey; // 빈 값 처리

    final list = Colors.primaries.where((c) {
      final hsl = HSLColor.fromColor(c);
      if (hsl.lightness >= .8) return false; // 너무 밝은 건 제외
      if (hsl.hue >= 40 && hsl.hue <= 80) return false; // 노란 계열 제외
      return true;
    }).toList();
    final pool = list.isNotEmpty ? list : Colors.primaries;
    return pool[key.hashCode.abs() % pool.length];
  }

  Widget _buildTag(String label, Color color) {
    if (label.isEmpty) return SizedBox.shrink(); // 빈 라벨 처리

    return Container(
      margin: EdgeInsets.only(right: 6),
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          // fontFamily: 'OngeulipKonKonche',
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tags = [];

    // 날씨는 이모지 (빈 값이 아닐 때만)
    if (weather.isNotEmpty && _weatherEmojiMap.containsKey(weather)) {
      tags.add(
        Container(
          margin: EdgeInsets.only(right: 6),
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _weatherEmojiMap[weather]!,
            style: TextStyle(fontSize: 15),
          ),
        ),
      );
    }

    // 감정 태그
    if (emotion.isNotEmpty && _emotionTextMap.containsKey(emotion)) {
      final eColor = _randomColor(emotion);
      tags.add(_buildTag(_emotionTextMap[emotion]!, eColor));
    }

    // 함께한 사람 태그
    if (socialContext.isNotEmpty && _socialTextMap.containsKey(socialContext)) {
      final sColor = _randomColor(socialContext);
      tags.add(_buildTag(_socialTextMap[socialContext]!, sColor));
    }

    // 활동 태그
    if (activityType.isNotEmpty && _activityTextMap.containsKey(activityType)) {
      final aColor = _randomColor(activityType);
      tags.add(_buildTag(_activityTextMap[activityType]!, aColor));
    }

    return Row(
      mainAxisSize: MainAxisSize.min, // 필요한 공간만 차지
      children: tags,
    );
  }
}
