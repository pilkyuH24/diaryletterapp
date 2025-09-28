// components/steps/diary_selection_step.dart
import 'package:flutter/material.dart';
import 'package:diaryletter/model/diary_model.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/widgets/ai/screens/letter_generate/components/widgets/step_header_widget.dart';
import 'package:diaryletter/widgets/ai/screens/letter_generate/components/widgets/diary_list_widget.dart';
import 'package:diaryletter/widgets/ai/services/letter_limit_service.dart';
import 'package:diaryletter/config/ad_config.dart'; // 🔧 광고 설정 import
// 광고 사용 시에만 import (AdConfig.isAdEnabled가 true일 때)
// import 'package:google_mobile_ads/google_mobile_ads.dart';

class DiarySelectionStep extends StatelessWidget {
  final List<DiaryModel> availableDiaries;
  final List<DiaryModel> selectedDiaries;
  final String userName;
  final Function(DiaryModel) onDiaryToggle;
  final VoidCallback onGenerateLetter;
  final ThemeProvider themeProv;
  final FontProvider fontProv;

  // 🔧 테스트용 디버그 모드
  static const bool kDebugMode = false;

  const DiarySelectionStep({
    Key? key,
    required this.availableDiaries,
    required this.selectedDiaries,
    required this.userName,
    required this.onDiaryToggle,
    required this.onGenerateLetter,
    required this.themeProv,
    required this.fontProv,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StepHeaderWidget(
          title: '분석할 일기를 선택해주세요',
          subtitle: '최근 30일 중의 일기들을 바탕으로 따뜻한 편지를 작성해드려요\n(최대 10개까지 선택 가능)',
          themeProv: themeProv,
          fontProv: fontProv,
        ),
        Expanded(
          child: DiaryListWidget(
            availableDiaries: availableDiaries,
            selectedDiaries: selectedDiaries,
            onDiaryToggle: onDiaryToggle,
            themeProv: themeProv,
            fontProv: fontProv,
          ),
        ),
        _buildBottomAction(context),
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    final c = themeProv.colors;
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.background,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Column(
        children: [
          if (selectedDiaries.isNotEmpty) _buildSelectionSummary(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: selectedDiaries.isEmpty
                  ? null
                  : () => _handleGenerateLetterTap(context),
              icon: Icon(Icons.auto_awesome, size: 24),
              label: Text(
                '$userName님의 편지 만들기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontProv.fontFamily.isEmpty
                      ? null
                      : fontProv.fontFamily,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedDiaries.isEmpty
                    ? Colors.grey[400]
                    : c.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: selectedDiaries.isEmpty ? 0 : 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔧 편지 만들기 버튼 탭 처리
  Future<void> _handleGenerateLetterTap(BuildContext context) async {
    try {
      final limitService = LetterLimitService();
      final canGenerate = await limitService.canGenerate();

      if (!canGenerate) {
        _showLimitDialog(context);
        return;
      }

      onGenerateLetter();
    } catch (e) {
      _showSnackBar(context, '제한 확인 중 오류가 발생했습니다: $e', isError: true);
    }
  }

  // 🔧 제한 도달 다이얼로그 (광고 기능 조건부 적용)
  void _showLimitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: themeProv.colors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            '제한 도달',
            style: TextStyle(
              color: themeProv.colors.textPrimary,
              fontFamily: fontProv.fontFamily.isEmpty
                  ? null
                  : fontProv.fontFamily,
            ),
          ),
          content: Text(
            AdConfig.isAdEnabled
                ? '오늘은 편지를 더 이상 받을 수 없어요.\n광고를 시청하면 3회를 추가할 수 있어요!'
                : '오늘은 편지를 더 이상 받을 수 없어요.\n내일 다시 시도해주세요!',
            style: TextStyle(
              color: themeProv.colors.textSecondary,
              fontFamily: fontProv.fontFamily.isEmpty
                  ? null
                  : fontProv.fontFamily,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AdConfig.isAdEnabled ? '취소' : '확인',
                style: TextStyle(
                  color: themeProv.colors.textPrimary,
                  fontFamily: fontProv.fontFamily.isEmpty
                      ? null
                      : fontProv.fontFamily,
                ),
              ),
            ),

            // 광고 기능이 활성화된 경우에만 광고 시청 버튼 표시
            if (AdConfig.isAdEnabled)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProv.colors.accent,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _showRewardedAd(context);
                },
                child: Text(
                  '광고 시청',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: fontProv.fontFamily.isEmpty
                        ? null
                        : fontProv.fontFamily,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // 🔧 테스트용 리밋 리셋 (디버그 모드에서만)
  Future<void> _resetLimitForTesting(BuildContext context) async {
    if (!kDebugMode) return;
    try {
      final limitService = LetterLimitService();
      await limitService.resetForTesting();
      _showSnackBar(context, '✅ 리밋이 리셋되었습니다!');
    } catch (e) {
      _showSnackBar(context, '❌ 리밋 리셋 실패: $e', isError: true);
    }
  }

  // 🔧 광고 시청 (광고 기능이 활성화된 경우에만 동작)
  void _showRewardedAd(BuildContext context) {
    if (!AdConfig.isAdEnabled) {
      _showSnackBar(context, '광고 기능이 비활성화되어 있습니다.', isError: true);
      return;
    }

    // 광고 기능을 사용할 때는 위의 import 주석을 해제하고 아래 주석을 해제하세요.
    /*
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1712485313', // TEST
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          ad.show(
            onUserEarnedReward: (AdWithoutView ad, RewardItem reward) async {
              final limitService = LetterLimitService();
              await limitService.increaseLimitByReward();
              _showSnackBar(context, '광고 시청 완료! 편지 3회 추가되었습니다 🎉');
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _showSnackBar(context, '광고 로드 실패: ${error.message}', isError: true);
        },
      ),
    );
    */
  }

  // 🔧 스낵바 표시
  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSelectionSummary() {
    final c = themeProv.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.primary.withOpacity(0.1), c.primary.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: themeProv.isDarkMode ? Colors.grey.shade500 : c.primary,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            '${selectedDiaries.length}개의 일기 선택됨',
            style: TextStyle(
              fontSize: 14,
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
              fontFamily: fontProv.fontFamily.isEmpty
                  ? null
                  : fontProv.fontFamily,
            ),
          ),
          if (selectedDiaries.length > 1) ...[
            SizedBox(width: 8),
            Text(
              '• ${_getSelectedDiariesSummary()}',
              style: TextStyle(
                fontSize: 12,
                color: c.textSecondary,
                fontFamily: fontProv.fontFamily.isEmpty
                    ? null
                    : fontProv.fontFamily,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getSelectedDiariesSummary() {
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

    return '$period 기간';
  }
}
