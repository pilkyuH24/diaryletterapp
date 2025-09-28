class DiaryModel {
  final String id;
  final String title;
  final String content;
  final DateTime date; // 일기 날짜 (YYYYMMDD → DateTime)
  final DateTime createdAt; // 작성 시간
  final String emotion; // 감정 상태
  final String weather; // 날씨
  final String socialContext; // 함께한 사람 (단수 선택)
  final String activityType; // 활동 유형

  DiaryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.createdAt,
    required this.emotion,
    required this.weather,
    required this.socialContext,
    required this.activityType,
  });

  DiaryModel.fromJson({required Map<String, dynamic> json})
    : id = json['id'],
      title = json['title'],
      content = json['content'],
      date = DateTime.parse(
        '${json['date'].substring(0, 4)}-${json['date'].substring(4, 6)}-${json['date'].substring(6, 8)}',
      ),
      createdAt = DateTime.parse(json['created_at']),
      emotion = json['emotion'] ?? 'happy',
      weather = json['weather'] ?? 'sunny',
      socialContext = (() {
        final sc = json['social_context'];
        if (sc == null) return 'alone';
        if (sc is String) return sc;
        if (sc is List && sc.isNotEmpty) return sc.first.toString();
        return 'alone';
      })(),
      activityType = json['activity_type'] ?? 'rest';

  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // Supabase에서 자동 생성한다면 제거
      'title': title,
      'content': content,
      'date':
          '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}',
      'created_at': createdAt.toIso8601String(),
      'emotion': emotion,
      'weather': weather,
      'social_context': socialContext,
      'activity_type': activityType,
    };
  }

  DiaryModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    DateTime? createdAt,
    String? emotion,
    String? weather,
    String? socialContext,
    String? activityType,
  }) {
    return DiaryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      emotion: emotion ?? this.emotion,
      weather: weather ?? this.weather,
      socialContext: socialContext ?? this.socialContext,
      activityType: activityType ?? this.activityType,
    );
  }
}
