import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/widgets/ai/services/letter_limit_service.dart';
import 'package:diaryletter/widgets/ads/reward_ad_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/widgets/ai/services/letter_service.dart';
import 'package:diaryletter/widgets/ai/services/user_name_service.dart';
import 'package:diaryletter/widgets/ai/components/ai_header_widget.dart';
import 'package:diaryletter/widgets/ai/components/main_actions_widget.dart';
import 'package:diaryletter/widgets/ai/components/future_features_widget.dart';
import 'package:diaryletter/widgets/ai/components/letter_limit_debug_widget.dart';
import 'package:diaryletter/widgets/ai/screens/letter_generate/letter_generate_screen.dart';
import 'package:diaryletter/widgets/ai/screens/letter_history/letter_history_screen.dart';
import 'package:diaryletter/config/ad_config.dart';

class AIScreen extends StatefulWidget {
  @override
  _AIScreenState createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  int _letterCount = 0;
  bool _isLoadingCount = true;
  late UserNameService _userNameService;
  late LetterLimitService _limitService;

  // 디버그 정보 새로고침을 위한 키
  int _debugRefreshKey = 0;

  @override
  void initState() {
    super.initState();
    _userNameService = UserNameService();
    _limitService = LetterLimitService();

    // 🔧 광고 서비스 초기화 (광고가 활성화되고 Android인 경우에만)
    if (AdConfig.isAdEnabled && Platform.isAndroid) {
      RewardAdService.initialize();
    }

    _loadLetterCount();
  }

  Future<void> _loadLetterCount() async {
    try {
      final count = await LetterService.getLetterCount();
      setState(() {
        _letterCount = count;
        _isLoadingCount = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCount = false;
      });
    }
  }

  /// 디버그 위젯의 리밋 정보를 새로고침
  void _refreshDebugInfo() {
    if (kDebugMode) {
      setState(() {
        _debugRefreshKey++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final tc = themeProv.colors;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [tc.surface, tc.surface, tc.accent.withOpacity(0.8)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AIHeaderWidget(),

                // 디버그 위젯 (디버그 모드에서만 표시)
                LetterLimitDebugWidget(
                  key: ValueKey(_debugRefreshKey),
                  onLimitChanged: () {
                    // 리밋이 변경되면 편지 카운트도 새로고침
                    _loadLetterCount();
                  },
                ),

                const SizedBox(height: 24),
                MainActionsWidget(
                  letterCount: _letterCount,
                  isLoadingCount: _isLoadingCount,
                  onLetterGenerate: _navigateToLetterGenerate,
                  onLetterHistory: _navigateToLetterHistory,
                ),
                const SizedBox(height: 40),
                FutureFeaturesWidget(onFeatureTap: _showComingSoon),
                const SizedBox(height: 72),
              ],
            ),
          ),
        ),
      ),

      // 디버그용 플로팅 액션 버튼 (디버그 모드에서만 표시)
      floatingActionButton: DebugFloatingActionButton(
        onRefresh: _refreshDebugInfo,
      ),
    );
  }

  void _navigateToLetterGenerate() async {
    try {
      final userName = await _userNameService.ensureUserName(context);
      if (userName == null) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LetterGenerateScreen(userName: userName),
        ),
      );

      if (result == true) {
        _loadLetterCount();
        // 디버그 모드에서는 리밋 정보도 새로고침
        _refreshDebugInfo();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e'), backgroundColor: Colors.red),
      );
      debugPrint('오류가 발생했습니다: $e');
    }
  }

  void _navigateToLetterHistory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LetterHistoryScreen()),
    );

    if (result == true) {
      _loadLetterCount();
    }
  }

  void _showComingSoon(String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('곧 만나요! 🚀'),
        content: Text('$featureName 기능을 열심히 개발 중이에요.\n조금만 기다려주세요!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 광고 시청을 통한 보너스 획득 (외부에서 호출 가능)
  void showRewardedAdFromDialog(BuildContext context) {
    // 🔧 광고 기능이 비활성화되었거나 iOS인 경우 실행하지 않음
    if (!AdConfig.isAdEnabled || Platform.isIOS) {
      if (kDebugMode) {
        debugPrint('🚫 광고 기능 비활성화 또는 iOS - 보상형 광고 건너뜀');
      }

      // 광고 없이 보상을 주거나 다른 대안 제시 (선택사항)
      _showAlternativeRewardDialog(context);
      return;
    }

    RewardAdService.show(
      context: context,
      onReward: () async {
        await _limitService.increaseLimitByReward();
        // 디버그 모드에서는 리밋 정보 새로고침
        _refreshDebugInfo();
      },
    );
  }

  /// 광고가 비활성화된 경우의 대안 (선택사항)
  void _showAlternativeRewardDialog(BuildContext context) {
    if (kDebugMode) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('🎯 개발 모드'),
          content: Text('광고 기능이 비활성화되어 있습니다.\n현재는 iOS 버전 출시를 위해 광고를 비활성화했습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
            ),
          ],
        ),
      );
    }
  }
}
