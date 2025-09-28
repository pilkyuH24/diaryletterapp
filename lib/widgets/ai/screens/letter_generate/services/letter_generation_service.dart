// services/letter_generation_service.dart
import 'package:diaryletter/model/diary_model.dart';
import 'package:diaryletter/widgets/diary/services/diary_service.dart';
import 'package:diaryletter/widgets/ai/services/ai_service.dart';
import 'package:diaryletter/widgets/ai/services/letter_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 결과 모델들
class DiariesLoadResult {
  final List<DiaryModel> diaries;
  final String? errorMessage;

  DiariesLoadResult({required this.diaries, this.errorMessage});
}

class DiarySelectionResult {
  final List<DiaryModel> selectedDiaries;
  final String? errorMessage;

  DiarySelectionResult({required this.selectedDiaries, this.errorMessage});
}

class LetterGenerationResult {
  final bool success;
  final String? title;
  final String? content;
  final String? errorMessage;

  LetterGenerationResult({
    required this.success,
    this.title,
    this.content,
    this.errorMessage,
  });
}

class LetterSaveResult {
  final bool success;
  final String? errorMessage;

  LetterSaveResult({required this.success, this.errorMessage});
}

class LetterGenerationService {
  static const int maxSelectableDiaries = 10;
  static const int autoSelectCount = 1;

  /// 최근 30일간의 일기들을 불러옵니다
  Future<DiariesLoadResult> loadAvailableDiaries() async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(Duration(days: 30));
      final diaries = await DiaryService.getDiariesByPeriod(thirtyDaysAgo, now);

      if (diaries.isEmpty) {
        return DiariesLoadResult(
          diaries: [],
          errorMessage: '최근 30일간 작성된 일기가 없어요.\n일기를 먼저 작성해보세요!',
        );
      }

      // ✅ 개선: 성공 시에만 간단한 로그
      if (kDebugMode) {
        debugPrint('📚 [Letter] 일기 ${diaries.length}개 로드됨');
      }

      return DiariesLoadResult(diaries: diaries);
    } catch (e) {
      // ✅ 유지: 에러는 항상 로그
      debugPrint('❌ [Letter] 일기 로드 실패: $e');
      return DiariesLoadResult(
        diaries: [],
        errorMessage: '일기를 불러오는 중 오류가 발생했어요.\n잠시 후 다시 시도해주세요.',
      );
    }
  }

  /// 최근 일기 자동 선택 (최대 3개)
  List<DiaryModel> autoSelectRecentDiaries(List<DiaryModel> availableDiaries) {
    if (availableDiaries.isEmpty) return [];

    final sorted = List<DiaryModel>.from(availableDiaries)
      ..sort((a, b) => b.date.compareTo(a.date));

    final selected = sorted.take(autoSelectCount).toList();

    // ✅ 개선: 디버그 모드에서만 자동 선택 로그
    if (kDebugMode && selected.isNotEmpty) {
      debugPrint('🎯 [Letter] 자동 선택: ${selected.length}개 일기');
    }

    return selected;
  }

  /// 일기 선택/해제 토글
  DiarySelectionResult toggleDiarySelection(
    List<DiaryModel> currentSelected,
    DiaryModel diary,
  ) {
    final newSelected = List<DiaryModel>.from(currentSelected);

    if (newSelected.contains(diary)) {
      newSelected.remove(diary);
      return DiarySelectionResult(selectedDiaries: newSelected);
    } else {
      if (newSelected.length >= maxSelectableDiaries) {
        return DiarySelectionResult(
          selectedDiaries: currentSelected,
          errorMessage: '최대 $maxSelectableDiaries개의 일기까지 선택할 수 있어요!',
        );
      }
      newSelected.add(diary);
      return DiarySelectionResult(selectedDiaries: newSelected);
    }
  }

  /// AI 편지 생성
  Future<LetterGenerationResult> generateLetter(
    List<DiaryModel> selectedDiaries,
    String userName,
  ) async {
    // ✅ 개선: 시작 로그 간소화
    debugPrint('🤖 [AI] 편지 생성 시작 - ${selectedDiaries.length}개 일기');

    try {
      final letterResponse = await AIService.generateLetter(
        selectedDiaries,
        userName,
      );

      // ✅ 개선: 성공 로그 간소화
      debugPrint('✅ [AI] 편지 생성 완료');

      return LetterGenerationResult(
        success: true,
        title: letterResponse.title,
        content: letterResponse.content,
      );
    } catch (e) {
      // ✅ 유지: 에러 로그 (사용자 친화적 메시지로 변경)
      debugPrint('❌ [AI] 편지 생성 실패: ${_getErrorType(e)}');
      return LetterGenerationResult(
        success: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// 편지 저장
  Future<LetterSaveResult> saveLetter(
    String title,
    String content,
    List<DiaryModel> selectedDiaries,
  ) async {
    try {
      await LetterService.saveLetter(title, content, selectedDiaries);

      // ✅ 개선: 성공 시 간단한 로그
      if (kDebugMode) {
        debugPrint('💾 [Letter] 편지 저장 완료');
      }

      return LetterSaveResult(success: true);
    } catch (e) {
      // ✅ 유지: 에러는 항상 로그
      debugPrint('❌ [Letter] 편지 저장 실패: $e');
      return LetterSaveResult(
        success: false,
        errorMessage: '편지 저장 중 오류가 발생했어요',
      );
    }
  }

  /// 선택된 일기들의 요약 정보 생성
  String getSelectedDiariesSummary(List<DiaryModel> selectedDiaries) {
    if (selectedDiaries.isEmpty) return '';

    final sorted = List<DiaryModel>.from(selectedDiaries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final start = sorted.first.date;
    final end = sorted.last.date;

    String period;
    if (start.month == end.month && start.day == end.day) {
      period = '${start.month}/${start.day}';
    } else if (start.month == end.month) {
      period = '${start.month}/${start.day}~${end.day}';
    } else {
      period = '${start.month}/${start.day}~${end.month}/${end.day}';
    }

    return '$period 기간 • ${selectedDiaries.length}개 일기';
  }

  /// ✅ 개선: 에러 타입 분류 (로그용)
  String _getErrorType(dynamic error) {
    final msg = error.toString();

    if (msg.contains('LetterLimitExceededException')) return '한도초과';
    if (msg.contains('개발 모드')) return '개발모드';
    if (msg.contains('네트워크') || msg.contains('timeout')) return '네트워크';
    if (msg.contains('서버') || msg.contains('503') || msg.contains('429'))
      return '서버과부하';
    return '기타오류';
  }

  /// 에러 메시지 생성 (사용자용)
  String _getErrorMessage(dynamic error) {
    final msg = error.toString();

    if (msg.contains('LetterLimitExceededException')) {
      return '오늘의 편지 생성 횟수를 모두 사용했어요.\n광고를 시청하면 추가 횟수를 받을 수 있어요! 📺';
    } else if (msg.contains('개발 모드')) {
      return '현재 개발 모드로 실행 중입니다.\n실제 AI 기능은 곧 활성화될 예정이에요! 🚀';
    } else if (msg.contains('네트워크') || msg.contains('timeout')) {
      return '인터넷 연결을 확인해주세요.\n잠시 후 다시 시도해보세요! 📶';
    } else if (msg.contains('서버') ||
        msg.contains('503') ||
        msg.contains('429')) {
      return 'AI 서버가 바쁜 상태예요.\n잠시 후 다시 시도해주세요! ⏰';
    } else {
      return 'AI 편지 생성 중 오류가 발생했어요.\n다시 시도해주세요! 💫';
    }
  }
}
