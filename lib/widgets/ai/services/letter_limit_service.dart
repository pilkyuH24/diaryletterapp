// lib/widgets/ai/services/letter_limit_service.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

/// 편지 생성 한도 관리 서비스
///
/// 기본 한도는 일일 3회이며, 광고 시청을 통해 보너스 한도를 획득할 수 있습니다.
/// 매일 자정에 사용량과 보너스가 자동으로 리셋됩니다.
class LetterLimitService {
  static const String _dateKey = 'letter_used_date';
  static const String _countKey = 'letter_used_count';
  static const String _bonusKey = 'letter_reward_bonus';
  static const int _baseLimit = 3;

  /// 오늘 날짜를 'yyyy-MM-dd' 형식으로 반환
  String _todayStr() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// 날짜가 변경되었으면 사용량과 보너스를 리셋
  Future<void> _resetIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayStr();
    final savedDate = prefs.getString(_dateKey);
    if (savedDate != today) {
      await prefs.setString(_dateKey, today);
      await prefs.setInt(_countKey, 0);
      await prefs.setInt(_bonusKey, 0);
    }
  }

  /// 오늘 사용한 편지 생성 횟수 반환
  Future<int> getUsedCount() async {
    await _resetIfNeeded();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_countKey) ?? 0;
  }

  /// 광고 시청으로 획득한 보너스 횟수 반환
  Future<int> getBonusCount() async {
    await _resetIfNeeded();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bonusKey) ?? 0;
  }

  /// 오늘의 총 편지 생성 한도 반환 (기본 한도 + 보너스)
  Future<int> getTotalLimit() async {
    return _baseLimit + await getBonusCount();
  }

  /// 편지 생성이 가능한지 확인
  Future<bool> canGenerate() async {
    final used = await getUsedCount();
    final total = await getTotalLimit();
    return used < total;
  }

  /// 남은 편지 생성 횟수 반환
  Future<int> getRemainingCount() async {
    final used = await getUsedCount();
    final total = await getTotalLimit();
    return (total - used).clamp(0, total);
  }

  /// 편지 생성 시 사용량 증가
  Future<void> consumeLetter() async {
    await _resetIfNeeded();
    final prefs = await SharedPreferences.getInstance();
    final used = await getUsedCount();
    await prefs.setInt(_countKey, used + 1);
  }

  /// 광고 시청 보상으로 편지 3회 추가
  Future<void> increaseLimitByReward() async {
    await _resetIfNeeded();
    final prefs = await SharedPreferences.getInstance();
    final currentBonus = await getBonusCount();
    await prefs.setInt(_bonusKey, currentBonus + 3);
  }

  /// 기본 일일 한도 반환 (상수)
  int get baseLimit => _baseLimit;

  // ========================================
  // 🔧 테스트용 메서드들 (개발 중에만 사용)
  // ========================================

  /// 테스트용: 오늘의 사용량과 보너스를 모두 0으로 리셋
  Future<void> resetForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayStr();
    await prefs.setString(_dateKey, today);
    await prefs.setInt(_countKey, 0);
    await prefs.setInt(_bonusKey, 0);
    debugPrint('🔧 [LetterLimitService] 테스트용 리셋 완료');
  }

  /// 테스트용: 현재 한도까지 사용량을 채움
  Future<void> fillLimitForTesting() async {
    await _resetIfNeeded();
    final total = await getTotalLimit();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, total);
    debugPrint('🔧 [LetterLimitService] 테스트용 한도 채우기 완료 ($total/$total)');
  }

  /// 테스트용: 특정 사용량으로 설정
  Future<void> setUsedCountForTesting(int count) async {
    await _resetIfNeeded();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, count);
    debugPrint('🔧 [LetterLimitService] 테스트용 사용량 설정: $count');
  }

  /// 테스트용: 특정 보너스량으로 설정
  Future<void> setBonusCountForTesting(int bonus) async {
    await _resetIfNeeded();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bonusKey, bonus);
    debugPrint('🔧 [LetterLimitService] 테스트용 보너스 설정: $bonus');
  }

  /// 테스트용: 현재 상태 로그 출력
  Future<void> printCurrentStateForTesting() async {
    final used = await getUsedCount();
    final bonus = await getBonusCount();
    final total = await getTotalLimit();
    final canGen = await canGenerate();
    final remaining = await getRemainingCount();

    debugPrint('🔧 [LetterLimitService] 현재 상태:');
    debugPrint('   - 기본 한도: $_baseLimit');
    debugPrint('   - 보너스: $bonus');
    debugPrint('   - 총 한도: $total');
    debugPrint('   - 사용량: $used');
    debugPrint('   - 생성 가능: $canGen');
    debugPrint('   - 남은 횟수: $remaining');
  }

  /// 테스트용: 모든 데이터 삭제 (완전 초기화)
  Future<void> clearAllDataForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dateKey);
    await prefs.remove(_countKey);
    await prefs.remove(_bonusKey);
    debugPrint('🔧 [LetterLimitService] 모든 데이터 삭제 완료');
  }
}
