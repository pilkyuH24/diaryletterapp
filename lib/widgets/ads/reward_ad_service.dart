import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:diaryletter/config/ad_config.dart';

class RewardAdService {
  static RewardedAd? _rewardedAd;
  static bool _isLoaded = false;

  /// 🚀 보상형 광고 서비스 초기화
  static void initialize() {
    // 🔧 광고가 비활성화된 경우 아무것도 하지 않음
    if (!AdConfig.isAdEnabled) {
      if (kDebugMode) debugPrint('📢 [RewardAd] 광고 비활성화 상태');
      return;
    }

    MobileAds.instance.initialize().then((_) => load());
  }

  /// 📥 보상형 광고 로드
  static void load() {
    // 🔧 광고가 비활성화된 경우 아무것도 하지 않음 + ios 광고 중지중
    if (!AdConfig.isAdEnabled || Platform.isIOS) return;

    if (_isLoaded) return;

    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoaded = true;
          if (kDebugMode) {
            debugPrint(
              '✅ [RewardAd] 로드 완료 (${AdConfig.rewardedAdUnitId.substring(0, 20)}...)',
            );
          }
        },
        onAdFailedToLoad: (error) {
          _isLoaded = false;
          debugPrint('❌ [RewardAd] 로드 실패: ${_getErrorType(error)}');

          // 🔄 자동 재시도
          Future.delayed(Duration(seconds: AdConfig.adRetryDelaySeconds), () {
            if (!_isLoaded) {
              if (kDebugMode) debugPrint('🔄 [RewardAd] 재시도');
              load();
            }
          });
        },
      ),
    );
  }

  /// 🎬 보상형 광고 표시
  static void show({
    required BuildContext context,
    required VoidCallback onReward,
  }) {
    // 🔧 광고가 비활성화된 경우
    if (!AdConfig.isAdEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고 기능이 비활성화되어 있습니다.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // 광고가 로드되지 않은 경우
    if (!_isLoaded || _rewardedAd == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('광고 준비 중입니다. 잠시 후 다시 시도하세요.'),
            action: SnackBarAction(
              label: '재시도',
              onPressed: load,
              textColor: Colors.white,
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    _rewardedAd!
      ..fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          if (kDebugMode) debugPrint('🚪 [RewardAd] 닫힘');
          ad.dispose();
          _isLoaded = false;
          load(); // 다음 광고 미리 로드
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('❌ [RewardAd] 표시 실패: $error');
          ad.dispose();
          _isLoaded = false;
          load(); // 다시 로드
        },
      )
      ..show(
        onUserEarnedReward: (ad, reward) {
          if (kDebugMode) {
            debugPrint('🎉 [RewardAd] 보상 획득: ${reward.amount} ${reward.type}');
          }

          onReward();

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  kDebugMode
                      ? '[TEST] 편지 ${AdConfig.rewardLetterCount}회 추가! (${reward.amount} ${reward.type})'
                      : '광고 시청 완료! 편지 ${AdConfig.rewardLetterCount}회 추가되었습니다 🎉',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      );
  }

  /// 📊 현재 광고 로드 상태
  static bool get isLoaded => AdConfig.isAdEnabled && _isLoaded;

  /// 🗑️ 리소스 정리
  static void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isLoaded = false;
  }

  /// 📋 현재 모드 정보 (디버깅용)
  static String get currentMode => kDebugMode ? 'TEST' : 'PRODUCTION';

  /// 📋 현재 광고 ID 정보 (디버깅용)
  static String get currentAdUnitId =>
      AdConfig.isAdEnabled ? AdConfig.rewardedAdUnitId : 'DISABLED';

  /// 📋 광고 상태 정보 (디버깅용)
  static String get statusInfo {
    if (!AdConfig.isAdEnabled) return '광고 비활성화';
    return '로드됨: $_isLoaded, 모드: $currentMode';
  }

  /// 🔍 에러 타입 문자열 변환
  static String _getErrorType(LoadAdError error) {
    switch (error.code) {
      case 0:
        return '내부오류 (${error.code})';
      case 1:
        return '네트워크오류 (${error.code})';
      case 2:
        return '광고없음 (${error.code})';
      case 3:
        return '앱ID오류 (${error.code})';
      default:
        return '알수없음 (${error.code}: ${error.message})';
    }
  }
}
