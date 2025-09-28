class LetterModel {
  final String id;
  final String title;
  final String content;
  final List<String> analyzedDiaryIds; // 분석에 사용된 일기 ID들
  final int diaryCount;
  final DateTime createdAt;
  final DateTime periodStart; // 분석 기간 시작
  final DateTime periodEnd; // 분석 기간 끝

  LetterModel({
    required this.id,
    required this.title,
    required this.content,
    required this.analyzedDiaryIds,
    required this.diaryCount,
    required this.createdAt,
    required this.periodStart,
    required this.periodEnd,
  });

  // JSON → LetterModel 변환
  LetterModel.fromJson({required Map<String, dynamic> json})
    : id = json['id'],
      title = json['title'],
      content = json['content'],
      analyzedDiaryIds = List<String>.from(json['analyzed_diary_ids'] ?? []),
      diaryCount = json['diary_count'] ?? 0,
      createdAt = DateTime.parse(json['created_at']),
      periodStart = DateTime.parse(json['period_start']),
      periodEnd = DateTime.parse(json['period_end']);

  // LetterModel → JSON 변환 (Supabase 저장용)
  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // Supabase에서 자동 생성
      'title': title,
      'content': content,
      'analyzed_diary_ids': analyzedDiaryIds,
      'diary_count': diaryCount,
      'created_at': createdAt.toIso8601String(),
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
    };
  }

  // 불변 객체 업데이트용
  LetterModel copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? analyzedDiaryIds,
    int? diaryCount,
    DateTime? createdAt,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    return LetterModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      analyzedDiaryIds: analyzedDiaryIds ?? this.analyzedDiaryIds,
      diaryCount: diaryCount ?? this.diaryCount,
      createdAt: createdAt ?? this.createdAt,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
    );
  }

  // 디버깅용 toString
  @override
  String toString() {
    return 'LetterModel(id: $id, title: $title, diaryCount: $diaryCount, createdAt: $createdAt)';
  }
}
