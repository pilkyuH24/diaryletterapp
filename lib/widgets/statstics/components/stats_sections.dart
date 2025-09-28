import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/const/colors.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/widgets/statstics/components/stats_common.dart';
import 'package:diaryletter/const/diary_option.dart';

/// Top 3 항목 + “더보기” ↔ 전체 차트 토글
class Top3StatsSection extends StatefulWidget {
  final String title;
  final String category; // 'emotion' 또는 'activity'
  final String compareLabel; // ex) '전월 대비 최근 30일'
  final Map<String, double> currentStats;
  final Map<String, double> previousStats;
  final Map<String, String> labels;
  final Map<String, Color> colors;

  const Top3StatsSection({
    Key? key,
    required this.title,
    required this.category,
    required this.compareLabel,
    required this.currentStats,
    required this.previousStats,
    required this.labels,
    required this.colors,
  }) : super(key: key);

  @override
  _Top3StatsSectionState createState() => _Top3StatsSectionState();
}

class _Top3StatsSectionState extends State<Top3StatsSection> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final entries = widget.currentStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final themeProv = context.watch<ThemeProvider>();
    final tc = themeProv.colors;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: BoxDecoration(
        color: tc.background,

        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: widget.title),
          Text(
            widget.compareLabel,
            style: TextStyle(
              // fontFamily: 'OngeulipKonKonche',
              fontSize: 12,
              color: (themeProv.isDarkMode ? DARK_TEXT : TEXT_PRIMARY_COLOR),
            ),
          ),
          SizedBox(height: 12),

          if (!isExpanded) ...[
            for (var entry in entries.take(3)) _buildItem(entry, entries),
            SizedBox(height: 12),
            Center(
              child: SizedBox(
                width: 120,
                child: OutlinedButton(
                  onPressed: () => setState(() => isExpanded = true),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: tc.surface),
                    backgroundColor: tc.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '더보기',
                    style: TextStyle(
                      color: (themeProv.isDarkMode
                          ? DARK_TEXT
                          : TEXT_PRIMARY_COLOR),
                      // fontFamily: 'OngeulipKonKonche',
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            ChartView(
              category: widget.category,
              currentStats: widget.currentStats,
              previousStats: widget.previousStats,
              labels: widget.labels,
              colors: widget.colors,
            ),
            SizedBox(height: 12),
            Center(
              child: SizedBox(
                width: 120,
                child: OutlinedButton(
                  onPressed: () => setState(() => isExpanded = false),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: tc.surface),
                    backgroundColor: tc.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '접기',
                    style: TextStyle(
                      color: (themeProv.isDarkMode
                          ? DARK_TEXT
                          : TEXT_PRIMARY_COLOR),
                      // fontFamily: 'OngeulipKonKonche',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItem(
    MapEntry<String, double> entry,
    List<MapEntry<String, double>> all,
  ) {
    final key = entry.key;
    final rank = all.indexWhere((e) => e.key == key) + 1;

    final prevList = widget.previousStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final prevRank = prevList.indexWhere((e) => e.key == key) + 1;
    final hasPrev = prevList.any((e) => e.key == key);
    final change = hasPrev ? prevRank - rank : 0;

    final iconPath = DiaryConstants.getIconPath(widget.category, key);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 15),
          RankBadge(rank: rank),
          SizedBox(width: 12),

          if (iconPath != null) ...[
            Image.asset(iconPath, width: 24, height: 24),
            SizedBox(width: 12),
          ],

          Expanded(
            child: Text(
              widget.labels[key] ?? key,
              style: TextStyle(
                // fontFamily: 'OngeulipKonKonche',
                fontSize: Platform.isIOS ? 18 : 14,
              ),
            ),
          ),
          SizedBox(width: 8),
          Text('${(entry.value * 100).toInt()}%'),
          SizedBox(width: 8),
          ChangeBadge(rankChange: change),
          SizedBox(width: 15),
        ],
      ),
    );
  }
}

/// ‘함께한 사람들’ 월간 비교 (ChartView + ChangeBadge)
class MonthlyComparisonSection extends StatelessWidget {
  final String title;
  final String compareLabel;
  final String category; // 'social'
  final Map<String, double> currentStats;
  final Map<String, double> previousStats;
  final Map<String, String> labels;
  final Map<String, Color> colors;

  const MonthlyComparisonSection({
    Key? key,
    required this.title,
    required this.compareLabel,
    required this.category,
    required this.currentStats,
    required this.previousStats,
    required this.labels,
    required this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final tc = themeProv.colors;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tc.background,

        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title),
          Text(
            compareLabel,
            style: TextStyle(
              // fontFamily: 'OngeulipKonKonche',
              fontSize: 12,
              color: (themeProv.isDarkMode ? DARK_TEXT : TEXT_PRIMARY_COLOR),
            ),
          ),
          SizedBox(height: 12),
          ChartView(
            category: category,
            currentStats: currentStats,
            previousStats: previousStats,
            labels: labels,
            colors: colors,
          ),
        ],
      ),
    );
  }
}
