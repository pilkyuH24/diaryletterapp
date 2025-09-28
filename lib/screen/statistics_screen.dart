// lib/screens/statistics_screen.dart

import 'package:diaryletter/config/system_ui_config.dart';
import 'package:diaryletter/const/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:diaryletter/const/diary_option.dart';
import 'package:diaryletter/model/diary_model.dart';
import 'package:diaryletter/widgets/statstics/utils/diary_stats_utils.dart';
import 'package:diaryletter/widgets/statstics/components/stat_cards.dart';
import 'package:diaryletter/widgets/statstics/components/stats_sections.dart';

class StatisticsScreen extends StatefulWidget {
  final ValueNotifier<bool>? refreshNotifier; // ← 추가

  const StatisticsScreen({Key? key, this.refreshNotifier}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<DiaryModel> _diaries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // refreshNotifier 가 토글될 때마다 다시 로드
    widget.refreshNotifier?.addListener(_loadDiaries);
    _loadDiaries();
  }

  @override
  void dispose() {
    widget.refreshNotifier?.removeListener(_loadDiaries);
    super.dispose();
  }

  Future<void> _loadDiaries() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('diary')
          .select()
          .order('date', ascending: false);
      if (!mounted) return;
      setState(() {
        _diaries = (response as List)
            .map((json) => DiaryModel.fromJson(json: json))
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final scheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('일기 로드에 실패했습니다.'),
          backgroundColor: scheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final fontProv = context.watch<FontProvider>();
    final tc = themeProv.colors;

    if (_isLoading) return _buildLoading(tc);
    if (_diaries.isEmpty) return _buildEmpty(tc);

    final monthly = DiaryStatsUtils.calculateMonthlyStats(_diaries);
    final diff = (monthly['difference'] ?? 0).toInt();
    final percent = (monthly['changePercent'] ?? 0).toInt();
    final streak = DiaryStatsUtils.calculateStreakDays(_diaries);
    final total = _diaries.length;
    final avgWords = DiaryStatsUtils.calculateAverageWordCount(_diaries);
    final hour = DiaryStatsUtils.calculateMostCommonHour(_diaries);
    final stats30 = DiaryStatsUtils.compute30DayStats(_diaries);
    const compareText = '최근 30일';

    final currentMonthly = (monthly['current'] ?? 0).toInt();
    final formattedStreak = NumberFormatter.formatLargeNumber(streak);
    final formattedTotal = NumberFormatter.formatLargeNumber(total);
    final formattedAvgWords = NumberFormatter.formatLargeNumber(avgWords);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        systemOverlayStyle: SystemUIConfig.getStatusBarStyle(
          themeProv.isDarkMode,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          '통계',
          style: TextStyle(
            color: tc.textPrimary,
            fontSize: ResponsiveFontSize.getValueFontSize(
              context,
              '통계',
              baseSize: 20,
              minSize: 18,
              maxSize: 22,
            ),
            fontWeight: FontWeight.w700,
            fontFamily: fontProv.fontFamily.isEmpty
                ? null
                : fontProv.fontFamily,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [tc.surface, tc.surface, tc.accent.withOpacity(0.8)],
          ),
        ),
        child: RefreshIndicator(
          color: tc.primary,
          onRefresh: _loadDiaries,
          backgroundColor: tc.surface,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              StatCard(
                title: '이번 달 일기 작성',
                value: '${NumberFormatter.formatLargeNumber(currentMonthly)}회',
                icon: Icons.calendar_today,
                subtitle:
                    '지난 달 대비 ${diff >= 0 ? '+' : ''}${NumberFormatter.formatLargeNumber(diff.abs())}회 (${percent >= 0 ? '+' : ''}$percent%)',
                color: tc.primary,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MiniStatCard(
                      title: '연속 작성',
                      value: '$formattedStreak일',
                      icon: Icons.local_fire_department,
                      color: tc.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MiniStatCard(
                      title: '총 일기 수',
                      value: '$formattedTotal개',
                      icon: Icons.book,
                      color: tc.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: MiniStatCard(
                      title: '평균 단어 수',
                      value: '$formattedAvgWords단어',
                      icon: Icons.text_fields,
                      color: tc.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MiniStatCard(
                      title: '작성 시간대',
                      value: DiaryStatsUtils.formatHour(hour),
                      icon: Icons.schedule,
                      color: tc.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Top3StatsSection(
                title: '기분 분석',
                category: 'emotion',
                compareLabel: compareText,
                currentStats: stats30.current,
                previousStats: stats30.previous,
                labels: DiaryConstants.emotionLabels,
                colors: DiaryConstants.emotionColors,
              ),
              const SizedBox(height: 28),
              Top3StatsSection(
                title: '활동 분석',
                category: 'activity',
                compareLabel: compareText,
                currentStats: stats30.currentActivity,
                previousStats: stats30.previousActivity,
                labels: DiaryConstants.activityLabels,
                colors: DiaryConstants.activityColors,
              ),
              const SizedBox(height: 28),
              MonthlyComparisonSection(
                title: '함께한 사람들',
                category: 'social',
                compareLabel: compareText,
                currentStats: stats30.currentSocial,
                previousStats: stats30.previousSocial,
                labels: DiaryConstants.socialLabels,
                colors: DiaryConstants.socialColors,
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(ThemeColors scheme) => Scaffold(
    backgroundColor: scheme.surface,
    body: Center(child: CircularProgressIndicator(color: scheme.primary)),
  );

  Widget _buildEmpty(ThemeColors scheme) =>
      Scaffold(backgroundColor: scheme.surface, body: EmptyStatsWidget());
}
