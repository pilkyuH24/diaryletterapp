// import 'dart:convert';
import 'package:diaryletter/widgets/ai/services/letter_limit_service.dart';
import 'package:diaryletter/model/diary_model.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// AI 응답 모델
class AILetterResponse {
  final String title;
  final String content;

  AILetterResponse({required this.title, required this.content});

  factory AILetterResponse.fromJson(Map<String, dynamic> json) {
    return AILetterResponse(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

/// ✅ 예외: 일일 생성 횟수 초과
class LetterLimitExceededException implements Exception {
  final String message;
  LetterLimitExceededException([this.message = '오늘은 편지를 더 생성할 수 없습니다.']);
  @override
  String toString() => message;
}

class AIConfig {
  static const bool ENABLE_AI_API = true; // 🚨 출시 시 true로 설정!

  static bool get canUseAI {
    if (kDebugMode && !ENABLE_AI_API) {
      return false;
    }
    return true;
  }

  // 🔧 이름을 포함한 더미 편지 생성 함수 (개발/테스트용)
  static AILetterResponse getDummyLetter(String userName) {
    return AILetterResponse(
      title: "$userName님의 소중한 일상들",
      content:
          '''
안녕하세요, $userName님! 💕

최근에 작성하신 일기들을 읽어보았어요.

여러 가지 감정을 느끼며 바쁜 시간을 보내신 것 같아요. 때로는 불안하고, 때로는 화가 나기도 하고, 생각이 많아지는 날들도 있었지만, 그 속에서도 행복한 순간들을 찾아내신 $userName님의 모습이 정말 멋져요.

힘든 감정들도 모두 소중한 $userName님의 일부라는 걸 잊지 마세요. 매일 일기를 쓰며 자신의 마음을 돌아보는 $userName님의 노력이 정말 대단합니다.

앞으로도 지금처럼 자신의 감정을 소중히 여기며, 매일매일 조금씩 성장해 나가시길 응원할게요!

마음을 담아 💝
$userName님을 응원하는 AI (개발 모드)
''',
    );
  }
}

class AIService {
  static final supabase = Supabase.instance.client;

  static Future<AILetterResponse> generateLetter(
    List<DiaryModel> diaries,
    String userName,
  ) async {
    // ✅ 개선: 개발 모드 체크 간소화
    if (!AIConfig.canUseAI) {
      if (kDebugMode) {
        debugPrint('🚨 [AI] 개발 모드 - 더미 편지 생성');
      }
      await Future.delayed(Duration(seconds: 2));
      return AIConfig.getDummyLetter(userName);
    }

    // ✅ 먼저 생성 가능 여부 확인
    final limitService = LetterLimitService();
    final canGenerate = await limitService.canGenerate();
    if (!canGenerate) {
      throw LetterLimitExceededException();
    }

    int maxRetries = 3;
    int retryDelay = 2;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // ✅ 개선: 첫 번째 시도에서만 로그
        if (attempt == 1 && kDebugMode) {
          debugPrint('🚀 [AI] API 호출 시작');
        }

        // 요청 데이터 준비
        final requestData = {
          'diaries': diaries
              .map(
                (diary) => {
                  'content': diary.content,
                  'date': diary.date.toIso8601String(),
                  'emotion': diary.emotion,
                  'weather': diary.weather,
                  'socialContext': diary.socialContext,
                  'activityType': diary.activityType,
                },
              )
              .toList(),
          'userName': userName,
        };

        // Supabase Edge Function 호출
        final response = await supabase.functions.invoke(
          'ai-proxy',
          body: requestData,
        );

        // 응답 데이터 확인
        final data = response.data;

        if (data == null) {
          throw Exception('Edge Function에서 응답 데이터가 없습니다');
        }

        // 에러 응답 체크
        if (data['error'] != null) {
          throw Exception('Edge Function 오류: ${data['error']}');
        }

        final letterResponse = AILetterResponse.fromJson(data);

        // ✅ 성공 시 횟수 차감
        await limitService.consumeLetter();

        // ✅ 개선: 성공 로그 간소화
        if (kDebugMode) {
          debugPrint('✅ [AI] API 호출 성공 (${attempt}번째 시도)');
        }

        return letterResponse;
      } on FunctionException catch (e) {
        // ✅ 개선: 서버 오류만 재시도 로그
        if (e.status == 503 || e.status == 429) {
          if (kDebugMode && attempt < maxRetries) {
            debugPrint('⏳ [AI] 서버 과부하 - 재시도 중 (${attempt}/$maxRetries)');
          }
          if (attempt < maxRetries) {
            await Future.delayed(Duration(seconds: retryDelay));
            retryDelay *= 2;
            continue;
          }
        }

        // ✅ 최종 실패 시에만 로그
        if (attempt == maxRetries) {
          debugPrint(
            '❌ [AI] Function Exception: ${_getErrorType(e.status)} (${e.status})',
          );
          throw Exception('AI 편지 생성 실패: ${e.details}');
        }

        await Future.delayed(Duration(seconds: retryDelay));
        retryDelay *= 2;
      } catch (e) {
        // ✅ 개선: 일반 오류도 최종 실패 시에만 상세 로그
        if (attempt == maxRetries) {
          debugPrint('❌ [AI] 일반 오류: ${_getGeneralErrorType(e)}');
          throw Exception('AI 편지 생성 실패: $e');
        }

        // ✅ 재시도 시에는 간단한 로그만
        if (kDebugMode && attempt < maxRetries) {
          debugPrint('⚠️ [AI] 재시도 중 (${attempt}/$maxRetries)');
        }

        await Future.delayed(Duration(seconds: retryDelay));
        retryDelay *= 2;
      }
    }
    throw Exception('최대 재시도 횟수 초과');
  }

  /// ✅ 추가: 에러 타입 분류 (FunctionException용)
  static String _getErrorType(int? status) {
    switch (status) {
      case 503:
        return '서비스불가';
      case 429:
        return '요청과다';
      case 400:
        return '잘못된요청';
      case 401:
        return '인증실패';
      case 500:
        return '서버오류';
      default:
        return '알수없음($status)';
    }
  }

  /// ✅ 추가: 일반 에러 타입 분류
  static String _getGeneralErrorType(dynamic error) {
    final msg = error.toString().toLowerCase();

    if (msg.contains('timeout')) return '타임아웃';
    if (msg.contains('network')) return '네트워크';
    if (msg.contains('connection')) return '연결실패';
    if (msg.contains('json')) return 'JSON파싱';
    return '기타오류';
  }
}
