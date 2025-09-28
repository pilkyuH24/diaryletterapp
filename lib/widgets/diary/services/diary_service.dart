import 'package:diaryletter/model/diary_model.dart';
import 'package:diaryletter/model/diary_filter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class DiaryLoadResult {
  final List<DiaryModel> diaries;
  final bool hasMore;

  DiaryLoadResult({required this.diaries, required this.hasMore});
}

// 🔧 필터링된 통계 정보를 담는 클래스
class FilteredStatistics {
  final Map<String, int> emotionCounts;
  final Map<String, int> socialCounts;
  final Map<String, int> activityCounts;
  final Map<String, int> weatherCounts;
  final int totalCount;

  FilteredStatistics({
    required this.emotionCounts,
    required this.socialCounts,
    required this.activityCounts,
    required this.weatherCounts,
    required this.totalCount,
  });

  static FilteredStatistics empty() {
    return FilteredStatistics(
      emotionCounts: {},
      socialCounts: {},
      activityCounts: {},
      weatherCounts: {},
      totalCount: 0,
    );
  }
}

class DiaryService {
  static const int pageSize = 10;
  static final _supabase = Supabase.instance.client;

  /// 페이지네이션으로 일기 목록 조회 (기존 메서드)
  static Future<DiaryLoadResult> loadDiaries(int page) async {
    try {
      final start = page * pageSize;
      final end = start + pageSize - 1;

      debugPrint('📚 [Diary Service] 일기 목록 조회 - 페이지 $page ($start~$end)');

      final response = await _supabase
          .from('diary')
          .select()
          .order('created_at', ascending: false)
          .range(start, end);

      final diaries = (response as List)
          .map((e) => DiaryModel.fromJson(json: e))
          .toList();

      debugPrint('✅ [Diary Service] 페이지 $page 조회 완료 - ${diaries.length}개');

      return DiaryLoadResult(
        diaries: diaries,
        hasMore: diaries.length == pageSize,
      );
    } catch (e) {
      debugPrint('❌ [Diary Service] 페이지 조회 중 오류: $e');
      throw Exception('일기 목록을 불러오지 못했습니다: $e');
    }
  }

  /// 🔧 복합 필터링으로 일기 조회 (새로운 메서드)
  static Future<List<DiaryModel>> getDiariesWithFilter(
    DiaryFilter filter,
  ) async {
    try {
      debugPrint('🔍 [Diary Service] 복합 필터링 조회 시작');
      debugPrint('   - 감정: ${filter.emotion}');
      debugPrint('   - 사회적 상황: ${filter.socialContext}');
      debugPrint('   - 활동: ${filter.activityType}');
      debugPrint('   - 날씨: ${filter.weather}');
      debugPrint('   - 년도: ${filter.year}');
      debugPrint('   - 월: ${filter.month}');
      debugPrint('   - 빠른 기간: ${filter.quickPeriod}');

      // 모든 일기를 가져와서 클라이언트에서 필터링
      // 성능을 위해 필요한 필드만 선택하고 최신순으로 정렬
      final response = await _supabase
          .from('diary')
          .select()
          .order('date', ascending: false)
          .order('created_at', ascending: false);

      final allDiaries = (response as List)
          .map((json) => DiaryModel.fromJson(json: json))
          .toList();

      // 클라이언트 사이드에서 복합 필터링 적용
      final filteredDiaries = allDiaries
          .where((diary) => filter.matches(diary))
          .toList();

      debugPrint(
        '✅ [Diary Service] 복합 필터링 완료 - ${filteredDiaries.length}개 (전체 ${allDiaries.length}개에서)',
      );
      return filteredDiaries;
    } catch (e) {
      debugPrint('❌ [Diary Service] 복합 필터링 중 오류: $e');
      throw Exception('필터링된 일기를 불러오지 못했습니다: $e');
    }
  }

  /// 🔧 필터링된 통계 정보 조회 (새로운 메서드)
  static Future<FilteredStatistics> getFilteredStatistics(
    DiaryFilter currentFilter,
  ) async {
    try {
      debugPrint('📊 [Diary Service] 필터링된 통계 조회 시작');

      // 모든 일기 데이터 가져오기
      final response = await _supabase.from('diary').select();
      final allDiaries = (response as List)
          .map((json) => DiaryModel.fromJson(json: json))
          .toList();

      // 현재 필터 조건을 제외한 각 카테고리별로 개수 계산
      final emotionCounts = <String, int>{};
      final socialCounts = <String, int>{};
      final activityCounts = <String, int>{};
      final weatherCounts = <String, int>{};

      for (final diary in allDiaries) {
        // 현재 필터에서 감정을 제외한 조건으로 필터링
        final filterWithoutEmotion = currentFilter.copyWith(clearEmotion: true);
        if (filterWithoutEmotion.matches(diary)) {
          emotionCounts[diary.emotion] =
              (emotionCounts[diary.emotion] ?? 0) + 1;
        }

        // 현재 필터에서 사회적 상황을 제외한 조건으로 필터링
        final filterWithoutSocial = currentFilter.copyWith(clearSocial: true);
        if (filterWithoutSocial.matches(diary)) {
          socialCounts[diary.socialContext] =
              (socialCounts[diary.socialContext] ?? 0) + 1;
        }

        // 현재 필터에서 활동을 제외한 조건으로 필터링
        final filterWithoutActivity = currentFilter.copyWith(
          clearActivity: true,
        );
        if (filterWithoutActivity.matches(diary)) {
          activityCounts[diary.activityType] =
              (activityCounts[diary.activityType] ?? 0) + 1;
        }

        // 현재 필터에서 날씨를 제외한 조건으로 필터링
        final filterWithoutWeather = currentFilter.copyWith(clearWeather: true);
        if (filterWithoutWeather.matches(diary)) {
          weatherCounts[diary.weather] =
              (weatherCounts[diary.weather] ?? 0) + 1;
        }
      }

      // 현재 필터 조건을 모두 적용한 총 개수
      final totalFilteredDiaries = allDiaries
          .where((diary) => currentFilter.matches(diary))
          .toList();

      debugPrint('✅ [Diary Service] 필터링된 통계 완료');
      debugPrint('   - 감정별 개수: $emotionCounts');
      debugPrint('   - 사회적 상황별 개수: $socialCounts');
      debugPrint('   - 활동별 개수: $activityCounts');
      debugPrint('   - 날씨별 개수: $weatherCounts');
      debugPrint('   - 총 개수: ${totalFilteredDiaries.length}');

      return FilteredStatistics(
        emotionCounts: emotionCounts,
        socialCounts: socialCounts,
        activityCounts: activityCounts,
        weatherCounts: weatherCounts,
        totalCount: totalFilteredDiaries.length,
      );
    } catch (e) {
      debugPrint('❌ [Diary Service] 필터링된 통계 조회 중 오류: $e');
      return FilteredStatistics.empty();
    }
  }

  /// 기간별 일기 조회 (YYYYMMDD 형식 사용)
  static Future<List<DiaryModel>> getDiariesByPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startDateString =
          '${startDate.year}${startDate.month.toString().padLeft(2, '0')}${startDate.day.toString().padLeft(2, '0')}';
      final endDateString =
          '${endDate.year}${endDate.month.toString().padLeft(2, '0')}${endDate.day.toString().padLeft(2, '0')}';

      debugPrint(
        '📅 [Diary Service] 기간별 일기 조회: $startDateString ~ $endDateString',
      );

      final response = await _supabase
          .from('diary')
          .select()
          .gte('date', startDateString)
          .lte('date', endDateString)
          .order('date', ascending: false)
          .order('created_at', ascending: false);

      final diaries = (response as List)
          .map((json) => DiaryModel.fromJson(json: json))
          .toList();

      debugPrint('✅ [Diary Service] 기간별 조회 완료 - ${diaries.length}개');
      return diaries;
    } catch (e) {
      debugPrint('❌ [Diary Service] 기간별 조회 중 오류: $e');
      throw Exception('기간별 일기를 불러오지 못했습니다: $e');
    }
  }

  /// 새 일기 저장
  static Future<String> saveDiary(DiaryModel diary) async {
    try {
      debugPrint('💾 [Diary Service] 일기 저장 시작: ${diary.title}');

      final response = await _supabase
          .from('diary')
          .insert(diary.toJson())
          .select('id')
          .single();

      final diaryId = response['id'] as String;
      debugPrint('✅ [Diary Service] 일기 저장 완료 - ID: $diaryId');
      return diaryId;
    } catch (e) {
      debugPrint('❌ [Diary Service] 일기 저장 중 오류: $e');
      throw Exception('일기 저장에 실패했습니다: $e');
    }
  }

  /// 기존 일기 수정
  static Future<void> updateDiary(DiaryModel diary) async {
    try {
      debugPrint('✏️ [Diary Service] 일기 수정 시작: ${diary.title}');

      await _supabase
          .from('diary')
          .update({
            'title': diary.title,
            'content': diary.content,
            'emotion': diary.emotion,
            'weather': diary.weather,
            'social_context': diary.socialContext,
            'activity_type': diary.activityType,
            // date는 수정하지 않음 (일기 날짜는 고정)
          })
          .eq('id', diary.id);

      debugPrint('✅ [Diary Service] 일기 수정 완료');
    } catch (e) {
      debugPrint('❌ [Diary Service] 일기 수정 중 오류: $e');
      throw Exception('일기 수정에 실패했습니다: $e');
    }
  }

  /// 일기 삭제
  static Future<void> deleteDiary(String diaryId) async {
    try {
      debugPrint('🗑️ [Diary Service] 일기 삭제 시작 - ID: $diaryId');

      await _supabase.from('diary').delete().eq('id', diaryId);

      debugPrint('✅ [Diary Service] 일기 삭제 완료');
    } catch (e) {
      debugPrint('❌ [Diary Service] 일기 삭제 중 오류: $e');
      throw Exception('일기 삭제에 실패했습니다: $e');
    }
  }

  /// 특정 일기 조회
  static Future<DiaryModel?> getDiary(String diaryId) async {
    try {
      debugPrint('📖 [Diary Service] 일기 조회 시작 - ID: $diaryId');

      final response = await _supabase
          .from('diary')
          .select()
          .eq('id', diaryId)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ [Diary Service] 일기를 찾을 수 없음 - ID: $diaryId');
        return null;
      }

      final diary = DiaryModel.fromJson(json: response);
      debugPrint('✅ [Diary Service] 일기 조회 완료: ${diary.title}');
      return diary;
    } catch (e) {
      debugPrint('❌ [Diary Service] 일기 조회 중 오류: $e');
      throw Exception('일기를 불러오지 못했습니다: $e');
    }
  }

  /// 특정 날짜의 일기 조회 (YYYYMMDD 형식)
  static Future<List<DiaryModel>> getDiariesByDate(DateTime date) async {
    try {
      final dateString =
          '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';

      debugPrint('📅 [Diary Service] 날짜별 일기 조회: $dateString');

      final response = await _supabase
          .from('diary')
          .select()
          .eq('date', dateString)
          .order('created_at', ascending: false);

      final diaries = (response as List)
          .map((json) => DiaryModel.fromJson(json: json))
          .toList();

      debugPrint('✅ [Diary Service] 날짜별 조회 완료 - ${diaries.length}개');
      return diaries;
    } catch (e) {
      debugPrint('❌ [Diary Service] 날짜별 조회 중 오류: $e');
      throw Exception('날짜별 일기를 불러오지 못했습니다: $e');
    }
  }

  /// 함께한 사람별 일기 조회
  static Future<List<DiaryModel>> getDiariesBySocialContext(
    String socialContext, {
    int? limit,
  }) async {
    try {
      debugPrint('👥 [Diary Service] 함께한 사람별 조회: $socialContext');

      var query = _supabase
          .from('diary')
          .select()
          .eq('social_context', socialContext)
          .order('date', ascending: false)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      final diaries = (response as List)
          .map((json) => DiaryModel.fromJson(json: json))
          .toList();

      debugPrint('✅ [Diary Service] 함께한 사람별 조회 완료 - ${diaries.length}개');
      return diaries;
    } catch (e) {
      debugPrint('❌ [Diary Service] 함께한 사람별 조회 중 오류: $e');
      throw Exception('함께한 사람별 일기를 불러오지 못했습니다: $e');
    }
  }

  /// 감정별 일기 조회
  static Future<List<DiaryModel>> getDiariesByEmotion(
    String emotion, {
    int? limit,
  }) async {
    try {
      debugPrint('😊 [Diary Service] 감정별 조회: $emotion');

      var query = _supabase
          .from('diary')
          .select()
          .eq('emotion', emotion)
          .order('date', ascending: false)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      final diaries = (response as List)
          .map((json) => DiaryModel.fromJson(json: json))
          .toList();

      debugPrint('✅ [Diary Service] 감정별 조회 완료 - ${diaries.length}개');
      return diaries;
    } catch (e) {
      debugPrint('❌ [Diary Service] 감정별 조회 중 오류: $e');
      throw Exception('감정별 일기를 불러오지 못했습니다: $e');
    }
  }

  /// 활동 유형별 일기 조회
  static Future<List<DiaryModel>> getDiariesByActivity(
    String activityType, {
    int? limit,
  }) async {
    try {
      debugPrint('🎯 [Diary Service] 활동별 조회: $activityType');

      var query = _supabase
          .from('diary')
          .select()
          .eq('activity_type', activityType)
          .order('date', ascending: false)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      final diaries = (response as List)
          .map((json) => DiaryModel.fromJson(json: json))
          .toList();

      debugPrint('✅ [Diary Service] 활동별 조회 완료 - ${diaries.length}개');
      return diaries;
    } catch (e) {
      debugPrint('❌ [Diary Service] 활동별 조회 중 오류: $e');
      throw Exception('활동별 일기를 불러오지 못했습니다: $e');
    }
  }

  /// 날씨별 일기 조회
  static Future<List<DiaryModel>> getDiariesByWeather(
    String weather, {
    int? limit,
  }) async {
    try {
      debugPrint('🌤️ [Diary Service] 날씨별 조회: $weather');

      var query = _supabase
          .from('diary')
          .select()
          .eq('weather', weather)
          .order('date', ascending: false)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      final diaries = (response as List)
          .map((json) => DiaryModel.fromJson(json: json))
          .toList();

      debugPrint('✅ [Diary Service] 날씨별 조회 완료 - ${diaries.length}개');
      return diaries;
    } catch (e) {
      debugPrint('❌ [Diary Service] 날씨별 조회 중 오류: $e');
      throw Exception('날씨별 일기를 불러오지 못했습니다: $e');
    }
  }

  /// 일기 개수 조회
  static Future<int> getDiaryCount() async {
    try {
      debugPrint('🔢 [Diary Service] 일기 개수 조회 시작');

      final response = await _supabase
          .from('diary')
          .select('id')
          .order('created_at', ascending: false);

      final count = (response as List).length;
      debugPrint('✅ [Diary Service] 일기 개수 조회 완료 - ${count}개');
      return count;
    } catch (e) {
      debugPrint('❌ [Diary Service] 일기 개수 조회 중 오류: $e');
      return 0;
    }
  }

  /// 최근 일기 조회 (간단한 메서드)
  static Future<List<DiaryModel>> getRecentDiaries({int limit = 10}) async {
    try {
      debugPrint('📋 [Diary Service] 최근 일기 조회 - 최대 ${limit}개');

      final response = await _supabase
          .from('diary')
          .select()
          .order('date', ascending: false)
          .order('created_at', ascending: false)
          .limit(limit);

      final diaries = (response as List)
          .map((json) => DiaryModel.fromJson(json: json))
          .toList();

      debugPrint('✅ [Diary Service] 최근 일기 조회 완료 - ${diaries.length}개');
      return diaries;
    } catch (e) {
      debugPrint('❌ [Diary Service] 최근 일기 조회 중 오류: $e');
      throw Exception('최근 일기를 불러오지 못했습니다: $e');
    }
  }

  /// 일기 검색 (제목 + 내용)
  static Future<List<DiaryModel>> searchDiaries(
    String keyword, {
    int? limit,
  }) async {
    try {
      debugPrint('🔍 [Diary Service] 일기 검색: "$keyword"');

      var query = _supabase
          .from('diary')
          .select()
          .or('title.ilike.%$keyword%,content.ilike.%$keyword%')
          .order('date', ascending: false)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      final diaries = (response as List)
          .map((json) => DiaryModel.fromJson(json: json))
          .toList();

      debugPrint('✅ [Diary Service] 검색 완료 - ${diaries.length}개 결과');
      return diaries;
    } catch (e) {
      debugPrint('❌ [Diary Service] 검색 중 오류: $e');
      throw Exception('일기 검색에 실패했습니다: $e');
    }
  }

  /// 통계용: 감정별 개수 조회
  static Future<Map<String, int>> getEmotionStatistics() async {
    try {
      debugPrint('📊 [Diary Service] 감정별 통계 조회 시작');

      final response = await _supabase.from('diary').select('emotion');

      final emotionCounts = <String, int>{};
      for (final row in response as List) {
        final emotion = row['emotion'] as String? ?? 'unknown';
        emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
      }

      debugPrint('✅ [Diary Service] 감정별 통계 조회 완료');
      return emotionCounts;
    } catch (e) {
      debugPrint('❌ [Diary Service] 감정별 통계 조회 중 오류: $e');
      return {};
    }
  }

  /// 특정 날짜에 일기가 있는지 확인
  static Future<bool> hasDiaryOnDate(DateTime date) async {
    try {
      final dateString =
          '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';

      final response = await _supabase
          .from('diary')
          .select('id')
          .eq('date', dateString)
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      debugPrint('❌ [Diary Service] 날짜별 일기 존재 확인 중 오류: $e');
      return false;
    }
  }
}
