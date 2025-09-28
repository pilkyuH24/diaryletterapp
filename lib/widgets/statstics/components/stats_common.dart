// lib/widgets/common_widgets.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/const/colors.dart';
import 'package:diaryletter/const/diary_option.dart';
import 'package:diaryletter/providers/theme_provider.dart';

/// 섹션 헤더 (타이틀만)
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    // final tc = themeProv.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          // fontFamily: 'OngeulipKonKonche',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: (themeProv.isDarkMode ? DARK_TEXT : TEXT_PRIMARY_COLOR),
        ),
      ),
    );
  }
}

/// 순위 배지 (원 안에 1,2,3)
class RankBadge extends StatelessWidget {
  final int rank;
  const RankBadge({Key? key, required this.rank}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color bg = rank == 1
        ? Colors.amber
        : rank == 2
        ? Colors.grey.shade400
        : Colors.brown.shade300;
    return CircleAvatar(
      backgroundColor: bg,
      radius: 16,
      child: Text(
        '$rank',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 순위/퍼센트 변화 배지
class ChangeBadge extends StatelessWidget {
  final int? rankChange;
  final int? percentChange;
  const ChangeBadge({Key? key, this.rankChange, this.percentChange})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (rankChange != null) {
      if (rankChange! > 0) {
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '▲',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontFamily: 'monospace', // 모노스페이스 폰트로 강제
                ),
              ),
              TextSpan(
                text: '${rankChange!}',
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
            ],
          ),
        );
      } else if (rankChange! < 0) {
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '▼',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontFamily: 'monospace', // 모노스페이스 폰트로 강제
                ),
              ),
              TextSpan(
                text: '${-rankChange!}',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ],
          ),
        );
      } else {
        return Text('–', style: TextStyle(color: Colors.grey, fontSize: 16));
      }
    } else if (percentChange != null) {
      final sign = percentChange! > 0 ? '+' : '';
      final color = percentChange! > 0
          ? Colors.green
          : percentChange! < 0
          ? Colors.red
          : Colors.grey;
      return Container(
        constraints: BoxConstraints(minWidth: 45, maxWidth: 80),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Text(
            '$sign${percentChange!}%',
            style: TextStyle(
              color: color,
              fontSize: Platform.isIOS ? 16 : 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }
}

/// 간단한 바차트 뷰 (current vs previous) + 아이콘
class ChartView extends StatelessWidget {
  final String category;
  final Map<String, double> currentStats;
  final Map<String, double> previousStats;
  final Map<String, String> labels;
  final Map<String, Color> colors;

  const ChartView({
    Key? key,
    required this.category,
    required this.currentStats,
    required this.previousStats,
    required this.labels,
    required this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final entries = currentStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: entries.map((entry) {
        final key = entry.key;
        final cur = entry.value;
        final prev = previousStats[key] ?? 0.0;
        final changePercent = ((cur - prev) * 100).toInt();
        final iconPath = DiaryConstants.getIconPath(category, key);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
          child: Row(
            children: [
              if (iconPath != null) ...[
                Image.asset(iconPath, width: 24, height: 24),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  labels[key] ?? key,
                  style: TextStyle(
                    // fontFamily: 'OngeulipKonKonche',
                    fontSize: Platform.isIOS ? 18 : 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 120,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(238, 238, 238, 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: prev.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: cur.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors[key] ?? Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40, // 고정 너비 설정
                alignment: Alignment.centerRight, // 오른쪽 정렬
                child: ChangeBadge(percentChange: changePercent),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
