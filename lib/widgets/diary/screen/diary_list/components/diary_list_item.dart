// lib/widgets/diary_list_item.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/model/diary_model.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/const/theme_colors.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/widgets/diary/components/diary_tags_row.dart';

class DiaryListItem extends StatelessWidget {
  final DiaryModel diary;
  final int index;
  final FontProvider fontProvider;
  final ThemeColors themeColors;
  final VoidCallback onTap;

  const DiaryListItem({
    Key? key,
    required this.diary,
    required this.index,
    required this.fontProvider,
    required this.themeColors,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + index * 60),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutSine,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 25 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.92 + 0.08 * value,
              child: _buildCard(context, value),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, double animationValue) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: themeColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1 * animationValue),
            spreadRadius: 0.5,
            blurRadius: 2,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: themeColors.primary.withOpacity(0.1),
          highlightColor: themeColors.primary.withOpacity(0.05),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 12),
                _buildTitle(),
                const SizedBox(height: 8),
                _buildContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildDateText(context),
            const SizedBox(width: 8),
            DiaryTagsRow(
              weather: diary.weather,
              emotion: diary.emotion,
              socialContext: diary.socialContext,
              activityType: diary.activityType,
            ),
          ],
        ),
        Text(
          '${diary.content.length}자',
          style: TextStyle(color: themeColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDateText(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 350 ? 14.0 : 16.0; // 화면 크기별 조정

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: diary.date.month.toString().padLeft(2, '0'),
            style: TextStyle(
              color: (themeProv.isDarkMode
                  ? themeColors.textPrimary
                  : themeColors.primary),
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
            ),
          ),
          TextSpan(
            text: '/',
            style: TextStyle(
              color: (themeProv.isDarkMode
                  ? themeColors.textPrimary
                  : themeColors.primary),
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          TextSpan(
            text: diary.date.day.toString().padLeft(2, '0'),
            style: TextStyle(
              color: (themeProv.isDarkMode
                  ? themeColors.textPrimary
                  : themeColors.primary),
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      diary.title,
      style: TextStyle(
        fontFamily: fontProvider.fontFamily.isEmpty
            ? null
            : fontProvider.fontFamily,
        fontSize: fontProvider.fontSize + 2,
        fontWeight: FontWeight.w700,
        color: themeColors.textPrimary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildContent() {
    return Text(
      diary.content,
      style: TextStyle(
        fontFamily: fontProvider.fontFamily.isEmpty
            ? null
            : fontProvider.fontFamily,
        fontSize: fontProvider.fontSize,
        color: themeColors.textPrimary.withOpacity(.9),
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}
