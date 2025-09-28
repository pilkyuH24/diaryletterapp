// lib/widgets/stat_cards.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/const/colors.dart';
import 'package:diaryletter/providers/theme_provider.dart';

/// 숫자 포맷팅 유틸리티
class NumberFormatter {
  static String formatLargeNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  static String extractNumberFromString(String text) {
    final regex = RegExp(r'\d+');
    final match = regex.firstMatch(text);
    return match?.group(0) ?? text;
  }
}

/// 반응형 폰트 크기 계산
class ResponsiveFontSize {
  static double getValueFontSize(
    BuildContext context,
    String text, {
    double baseSize = 20,
    double minSize = 12,
    double maxSize = 24,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textLength = text.length;
    final isIOS = Platform.isIOS;

    // 화면 크기에 따른 기본 조정 (더 세분화)
    double screenFactor;
    if (screenWidth < 340) {
      // 매우 작은 화면
      screenFactor = 0.8;
    } else if (screenWidth < 375) {
      // 작은 화면 (iPhone SE 미만)
      screenFactor = 0.9;
    } else if (screenWidth < 400) {
      // 중간 화면 (iPhone 14 기준)
      screenFactor = 1.0;
    } else if (screenWidth < 430) {
      // 큰 화면 (Pixel, iPhone Pro)
      screenFactor = 1.1;
    } else {
      // 매우 큰 화면 (iPhone Plus)
      screenFactor = 1.15;
    }

    // iOS는 약간 더 큰 폰트 사용
    if (isIOS) {
      screenFactor *= 1.05;
    }

    // 텍스트 길이에 따른 조정
    double lengthFactor = textLength <= 3
        ? 1.0
        : textLength <= 6
        ? 0.9
        : textLength <= 9
        ? 0.8
        : 0.7;

    double calculatedSize = baseSize * screenFactor * lengthFactor;

    return calculatedSize.clamp(minSize, maxSize);
  }

  static double getTitleFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isIOS = Platform.isIOS;

    double size;
    if (screenWidth < 340) {
      size = 12;
    } else if (screenWidth < 375) {
      size = 13;
    } else {
      size = 14;
    }

    return isIOS ? size + 0.5 : size;
  }

  static double getSubtitleFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isIOS = Platform.isIOS;

    double size;
    if (screenWidth < 340) {
      // 매우 작은 화면
      size = isIOS ? 12 : 11;
    } else if (screenWidth < 375) {
      // 작은 화면
      size = isIOS ? 13 : 12;
    } else if (screenWidth < 430) {
      // 중간~큰 화면
      size = isIOS ? 14 : 13;
    } else {
      // 매우 큰 화면
      size = isIOS ? 15 : 14;
    }

    return size;
  }
}

/// 메인 통계 카드 (개선된 버전)
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String subtitle;
  final Color color;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.subtitle,
    required this.color,
  }) : super(key: key);

  Color _getIconColor() {
    switch (icon) {
      case Icons.calendar_today:
        return Colors.orange[600]!;
      default:
        return color;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final tc = themeProv.colors;
    final iconColor = _getIconColor();
    final screenWidth = MediaQuery.of(context).size.width;

    // 화면 크기에 따른 패딩 조정 (더 세분화)
    double padding, iconPadding, iconSize, spacing;

    if (screenWidth < 340) {
      // 매우 작은 화면
      padding = 14.0;
      iconPadding = 8.0;
      iconSize = 20.0;
      spacing = 10.0;
    } else if (screenWidth < 375) {
      // 작은 화면
      padding = 16.0;
      iconPadding = 10.0;
      iconSize = 22.0;
      spacing = 12.0;
    } else {
      // 중간 이상 화면
      padding = 20.0;
      iconPadding = 12.0;
      iconSize = 24.0;
      spacing = 16.0;
    }

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: tc.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(iconPadding),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: iconSize),
          ),
          SizedBox(width: screenWidth < 350 ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveFontSize.getTitleFontSize(context),
                    fontWeight: FontWeight.w500,
                    color: tc.textSecondary,
                  ),
                ),
                SizedBox(height: 4),
                // FittedBox로 오버플로우 방지
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: ResponsiveFontSize.getValueFontSize(
                        context,
                        value,
                        baseSize: Platform.isIOS ? 22 : 20,
                        minSize: 16,
                        maxSize: 26,
                      ),
                      fontWeight: FontWeight.w700,
                      color: tc.textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: ResponsiveFontSize.getSubtitleFontSize(context),
                    fontWeight: FontWeight.w500,
                    color: tc.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 미니 통계 카드 (개선된 버전)
class MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const MiniStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  Color _getIconColor() {
    switch (icon) {
      case Icons.local_fire_department:
        return Colors.red[600]!;
      case Icons.book:
        return Colors.blue[600]!;
      case Icons.text_fields:
        return Colors.indigo[500]!;
      case Icons.schedule:
        return Colors.amber[700]!;
      default:
        return color;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final tc = themeProv.colors;
    final iconColor = _getIconColor();
    final screenWidth = MediaQuery.of(context).size.width;

    // 화면 크기에 따른 조정
    final padding = screenWidth < 350 ? 12.0 : 16.0;
    final iconPadding = screenWidth < 350 ? 8.0 : 10.0;
    final iconSize = screenWidth < 350 ? 20.0 : 24.0;
    final spacing = screenWidth < 350 ? 8.0 : 12.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: tc.background,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(iconPadding),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: iconSize),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: screenWidth < 350 ? 8 : 14),
                // FittedBox로 오버플로우 방지
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: ResponsiveFontSize.getValueFontSize(
                        context,
                        value,
                        baseSize: Platform.isIOS ? 20 : 16,
                        minSize: 14,
                        maxSize: 22,
                      ),
                      fontWeight: FontWeight.w700,
                      color: tc.textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveFontSize.getSubtitleFontSize(context),
                      fontWeight: FontWeight.w500,
                      color: tc.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: screenWidth < 350 ? 8 : 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 일기 없을 때 표시 (개선된 버전)
class EmptyStatsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final tc = themeProv.colors;
    final screenWidth = MediaQuery.of(context).size.width;

    final iconSize = screenWidth < 350 ? 48.0 : 64.0;
    final titleSize = screenWidth < 350 ? 16.0 : 18.0;
    final subtitleSize = screenWidth < 350 ? 14.0 : 16.0;
    final padding = screenWidth < 350 ? 24.0 : 32.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: tc.textPrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bar_chart,
                size: iconSize,
                color: tc.background,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '통계를 보려면 일기를 작성해주세요',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
                color: tc.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              '첫 번째 일기를 작성하고\n나만의 통계를 확인해보세요!',
              style: TextStyle(fontSize: subtitleSize, color: tc.textPrimary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 곧 추가될 기능 안내 (개선된 버전)
class ComingSoonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth < 350 ? 40.0 : 48.0;
    final titleSize = screenWidth < 350 ? 16.0 : 18.0;
    final subtitleSize = screenWidth < 350 ? 12.0 : 14.0;
    final padding = screenWidth < 350 ? 20.0 : 24.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[100]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.construction, size: iconSize, color: Colors.purple[300]),
          SizedBox(height: 16),
          Text(
            '더 많은 통계 기능 준비 중!',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w600,
              color: Colors.purple[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            '감정 변화 그래프, 월별 비교 등\n다양한 분석 기능이 곧 추가됩니다',
            style: TextStyle(fontSize: subtitleSize, color: Colors.purple[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
