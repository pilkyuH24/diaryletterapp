import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:diaryletter/model/letter_model.dart';
import 'package:diaryletter/model/diary_model.dart';

class LetterService {
  static final _supabase = Supabase.instance.client;

  /// 편지 저장
  /// [content] AI가 생성한 편지 내용
  /// [analyzedDiaries] 분석에 사용된 일기들
  /// Returns: 저장된 편지의 ID
  static Future<String> saveLetter(
    String title,
    String content,
    List<DiaryModel> analyzedDiaries,
  ) async {
    try {
      debugPrint('💾 [Letter Service] 편지 저장 시작');

      // 현재 사용자 확인
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      // 분석 기간 계산
      final sortedDiaries = List<DiaryModel>.from(analyzedDiaries)
        ..sort((a, b) => a.date.compareTo(b.date));

      final periodStart = sortedDiaries.first.date;
      final periodEnd = sortedDiaries.last.date;
      final diaryIds = analyzedDiaries.map((d) => d.id).toList();
      final diaryCount = analyzedDiaries.length;

      debugPrint('📝 [Letter Service] 편지 정보:');
      debugPrint('  사용자 ID: ${user.id}');
      debugPrint('  제목: $title');
      debugPrint(
        '  분석 기간: ${periodStart.month}/${periodStart.day} ~ ${periodEnd.month}/${periodEnd.day}',
      );
      debugPrint('  일기 개수: $diaryCount개');

      // LetterModel 생성
      final letter = LetterModel(
        id: '', // Supabase에서 자동 생성
        title: title,
        content: content,
        analyzedDiaryIds: diaryIds,
        diaryCount: diaryCount,
        createdAt: DateTime.now(),
        periodStart: periodStart,
        periodEnd: periodEnd,
      );

      // Supabase에 저장 (user_id 포함)
      final letterData = letter.toJson();
      letterData['user_id'] = user.id; // 사용자 ID 추가

      final response = await _supabase
          .from('letters')
          .insert(letterData)
          .select('id')
          .single();

      final letterId = response['id'] as String;

      debugPrint('✅ [Letter Service] 편지 저장 완료 - ID: $letterId');
      return letterId;
    } catch (e) {
      debugPrint('❌ [Letter Service] 편지 저장 중 오류: $e');
      throw Exception('편지 저장에 실패했습니다: $e');
    }
  }

  /// 편지 목록 조회 (최신순)
  /// [limit] 가져올 편지 개수 (기본 20개)
  /// Returns: 편지 목록
  static Future<List<LetterModel>> getLetters({int limit = 20}) async {
    try {
      // 현재 사용자 확인
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ [Letter Service] 로그인되지 않은 상태 - 빈 목록 반환');
        return [];
      }

      final response = await _supabase
          .from('letters')
          .select()
          .eq('user_id', user.id) // 사용자별 필터링
          .order('created_at', ascending: false)
          .limit(limit);

      final letters = (response as List)
          .map(
            (json) => LetterModel.fromJson(json: json as Map<String, dynamic>),
          )
          .toList();

      debugPrint('✅ [Letter Service] 편지 목록 조회 완료 - ${letters.length}개');
      return letters;
    } catch (e) {
      debugPrint('❌ [Letter Service] 편지 목록 조회 중 오류: $e');
      throw Exception('편지 목록을 불러오지 못했습니다: $e');
    }
  }

  /// 특정 편지 조회
  /// [letterId] 편지 ID
  /// Returns: 편지 또는 null
  static Future<LetterModel?> getLetter(String letterId) async {
    try {
      debugPrint('📖 [Letter Service] 편지 조회 시작 - ID: $letterId');

      // 현재 사용자 확인
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ [Letter Service] 로그인되지 않은 상태');
        return null;
      }

      final response = await _supabase
          .from('letters')
          .select()
          .eq('id', letterId)
          .eq('user_id', user.id) // 사용자별 필터링
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ [Letter Service] 편지를 찾을 수 없음 - ID: $letterId');
        return null;
      }

      final letter = LetterModel.fromJson(json: response);

      debugPrint('✅ [Letter Service] 편지 조회 완료 - ${letter.title}');
      return letter;
    } catch (e) {
      debugPrint('❌ [Letter Service] 편지 조회 중 오류: $e');
      throw Exception('편지를 불러오지 못했습니다: $e');
    }
  }

  /// 편지 삭제
  /// [letterId] 삭제할 편지 ID
  /// Returns: 삭제 성공 여부
  static Future<bool> deleteLetter(String letterId) async {
    try {
      debugPrint('🗑️ [Letter Service] 편지 삭제 시작 - ID: $letterId');

      // 현재 사용자 확인
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      await _supabase
          .from('letters')
          .delete()
          .eq('id', letterId)
          .eq('user_id', user.id); // 사용자별 필터링

      debugPrint('✅ [Letter Service] 편지 삭제 완료');
      return true;
    } catch (e) {
      debugPrint('❌ [Letter Service] 편지 삭제 중 오류: $e');
      throw Exception('편지 삭제에 실패했습니다: $e');
    }
  }

  /// 편지 개수 조회 (간단한 방식)
  /// Returns: 저장된 편지 총 개수
  static Future<int> getLetterCount() async {
    try {
      debugPrint('🔢 [Letter Service] 편지 개수 조회 시작');

      // 현재 사용자 확인
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ [Letter Service] 로그인되지 않은 상태 - 0개 반환');
        return 0;
      }

      final response = await _supabase
          .from('letters')
          .select('id') // id만 가져와서 효율성 높임
          .eq('user_id', user.id) // 사용자별 필터링
          .order('created_at', ascending: false);

      final count = (response as List).length;

      debugPrint('✅ [Letter Service] 편지 개수 조회 완료 - ${count}개');
      return count;
    } catch (e) {
      debugPrint('❌ [Letter Service] 편지 개수 조회 중 오류: $e');
      return 0;
    }
  }

  /// 특정 기간의 편지 조회
  /// [startDate] 시작 날짜
  /// [endDate] 끝 날짜
  /// Returns: 해당 기간의 편지 목록
  static Future<List<LetterModel>> getLettersByPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      debugPrint('📅 [Letter Service] 기간별 편지 조회 시작');
      debugPrint(
        '  기간: ${startDate.toIso8601String()} ~ ${endDate.toIso8601String()}',
      );

      // 현재 사용자 확인
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ [Letter Service] 로그인되지 않은 상태 - 빈 목록 반환');
        return [];
      }

      final response = await _supabase
          .from('letters')
          .select()
          .eq('user_id', user.id) // 사용자별 필터링
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: false);

      final letters = (response as List)
          .map(
            (json) => LetterModel.fromJson(json: json as Map<String, dynamic>),
          )
          .toList();

      debugPrint('✅ [Letter Service] 기간별 편지 조회 완료 - ${letters.length}개');
      return letters;
    } catch (e) {
      debugPrint('❌ [Letter Service] 기간별 편지 조회 중 오류: $e');
      throw Exception('기간별 편지를 불러오지 못했습니다: $e');
    }
  }

  /// 편지 제목 업데이트
  /// [letterId] 편지 ID
  /// [newTitle] 새로운 제목
  /// Returns: 업데이트 성공 여부
  static Future<bool> updateLetterTitle(
    String letterId,
    String newTitle,
  ) async {
    try {
      debugPrint('✏️ [Letter Service] 편지 제목 수정 시작');
      debugPrint('  ID: $letterId, 새 제목: $newTitle');

      // 현재 사용자 확인
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      await _supabase
          .from('letters')
          .update({'title': newTitle})
          .eq('id', letterId)
          .eq('user_id', user.id); // 사용자별 필터링

      debugPrint('✅ [Letter Service] 편지 제목 수정 완료');
      return true;
    } catch (e) {
      debugPrint('❌ [Letter Service] 편지 제목 수정 중 오류: $e');
      throw Exception('편지 제목 수정에 실패했습니다: $e');
    }
  }

  /// 최근 편지 조회 (간단한 메서드)
  /// [limit] 가져올 편지 개수 (기본 5개)
  /// Returns: 최근 편지 목록
  static Future<List<LetterModel>> getRecentLetters({int limit = 5}) async {
    try {
      debugPrint('📋 [Letter Service] 최근 편지 조회 시작 - 최대 ${limit}개');

      // 현재 사용자 확인
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ [Letter Service] 로그인되지 않은 상태 - 빈 목록 반환');
        return [];
      }

      final response = await _supabase
          .from('letters')
          .select()
          .eq('user_id', user.id) // 사용자별 필터링
          .order('created_at', ascending: false)
          .limit(limit);

      final letters = (response as List)
          .map(
            (json) => LetterModel.fromJson(json: json as Map<String, dynamic>),
          )
          .toList();

      debugPrint('✅ [Letter Service] 최근 편지 조회 완료 - ${letters.length}개');
      return letters;
    } catch (e) {
      debugPrint('❌ [Letter Service] 최근 편지 조회 중 오류: $e');
      throw Exception('최근 편지를 불러오지 못했습니다: $e');
    }
  }

  /// 편지 검색 (제목 + 내용)
  /// [keyword] 검색 키워드
  /// [limit] 최대 결과 개수
  /// Returns: 검색된 편지 목록
  static Future<List<LetterModel>> searchLetters(
    String keyword, {
    int? limit,
  }) async {
    try {
      debugPrint('🔍 [Letter Service] 편지 검색: "$keyword"');

      // 현재 사용자 확인
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ [Letter Service] 로그인되지 않은 상태 - 빈 목록 반환');
        return [];
      }

      var query = _supabase
          .from('letters')
          .select()
          .eq('user_id', user.id) // 사용자별 필터링
          .or('title.ilike.%$keyword%,content.ilike.%$keyword%')
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      final letters = (response as List)
          .map(
            (json) => LetterModel.fromJson(json: json as Map<String, dynamic>),
          )
          .toList();

      debugPrint('✅ [Letter Service] 편지 검색 완료 - ${letters.length}개 결과');
      return letters;
    } catch (e) {
      debugPrint('❌ [Letter Service] 편지 검색 중 오류: $e');
      throw Exception('편지 검색에 실패했습니다: $e');
    }
  }

  /// 편지 통계 조회
  /// Returns: 편지 관련 통계 정보
  static Future<Map<String, dynamic>> getLetterStatistics() async {
    try {
      debugPrint('📊 [Letter Service] 편지 통계 조회 시작');

      // 현재 사용자 확인
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ [Letter Service] 로그인되지 않은 상태 - 빈 통계 반환');
        return {
          'totalCount': 0,
          'thisMonthCount': 0,
          'lastMonthCount': 0,
          'avgDiariesPerLetter': 0.0,
        };
      }

      // 전체 편지 개수
      final totalResponse = await _supabase
          .from('letters')
          .select('id, diary_count')
          .eq('user_id', user.id);

      final totalData = totalResponse as List;
      final totalCount = totalData.length;

      // 이번 달 편지 개수
      final now = DateTime.now();
      final thisMonthStart = DateTime(now.year, now.month, 1);
      final nextMonthStart = DateTime(now.year, now.month + 1, 1);

      final thisMonthResponse = await _supabase
          .from('letters')
          .select('id')
          .eq('user_id', user.id)
          .gte('created_at', thisMonthStart.toIso8601String())
          .lt('created_at', nextMonthStart.toIso8601String());

      final thisMonthCount = (thisMonthResponse as List).length;

      // 지난 달 편지 개수
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);
      final lastMonthEnd = thisMonthStart;

      final lastMonthResponse = await _supabase
          .from('letters')
          .select('id')
          .eq('user_id', user.id)
          .gte('created_at', lastMonthStart.toIso8601String())
          .lt('created_at', lastMonthEnd.toIso8601String());

      final lastMonthCount = (lastMonthResponse as List).length;

      // 편지당 평균 일기 개수
      double avgDiariesPerLetter = 0.0;
      if (totalCount > 0) {
        final totalDiaries = totalData
            .map(
              (letter) =>
                  (letter as Map<String, dynamic>)['diary_count'] as int? ?? 0,
            )
            .fold<int>(0, (sum, count) => sum + count);
        avgDiariesPerLetter = totalDiaries / totalCount;
      }

      final statistics = {
        'totalCount': totalCount,
        'thisMonthCount': thisMonthCount,
        'lastMonthCount': lastMonthCount,
        'avgDiariesPerLetter': avgDiariesPerLetter,
      };

      debugPrint('✅ [Letter Service] 편지 통계 조회 완료');
      debugPrint(
        '  전체: ${totalCount}개, 이번달: ${thisMonthCount}개, 지난달: ${lastMonthCount}개',
      );
      return statistics;
    } catch (e) {
      debugPrint('❌ [Letter Service] 편지 통계 조회 중 오류: $e');
      return {
        'totalCount': 0,
        'thisMonthCount': 0,
        'lastMonthCount': 0,
        'avgDiariesPerLetter': 0.0,
      };
    }
  }
}
