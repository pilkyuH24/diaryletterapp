import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/const/colors.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/widgets/diary/components/diary_tags_row.dart';

// home_screen에서 사용
class DiaryCard extends StatelessWidget {
  final String title;
  final String content;
  final DateTime createdAt;
  final String emotion;
  final String weather;
  final String socialContext;
  final String activityType;
  final VoidCallback? onTap;
  final bool useFontProvider;

  const DiaryCard({
    Key? key,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.emotion,
    required this.weather,
    required this.socialContext,
    required this.activityType,
    this.onTap,
    this.useFontProvider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final scheme = Theme.of(context).colorScheme;
    final themeProv = context.watch<ThemeProvider>();

    return Card(
      color: themeProv.colors.background,
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              _buildTitle(context),
              SizedBox(height: 8),

              // 내용 미리보기
              _buildContent(context),
              SizedBox(height: 12),

              // 작성 시간 + 태그들
              _buildCreatedAt(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final themeColors = context.watch<ThemeProvider>().colors;

    if (useFontProvider) {
      return Consumer<FontProvider>(
        builder: (context, fontProvider, child) => Text(
          title,
          style: fontProvider.getTitleTextStyle(color: themeColors.textPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    } else {
      return Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: PRIMARY_COLOR,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget _buildContent(BuildContext context) {
    final themeColors = context.watch<ThemeProvider>().colors;

    if (useFontProvider) {
      return Consumer<FontProvider>(
        builder: (context, fontProvider, child) => Text(
          content,
          style: fontProvider.getTextStyle(
            customSize: fontProvider.fontSize - 2,
            color: themeColors.textPrimary,
            height: 1.5,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      );
    } else {
      return Text(
        content,
        style: TextStyle(
          fontSize: 14,
          color: themeColors.textPrimary,
          height: 1.5,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget _buildCreatedAt(BuildContext context) {
    final timeString =
        '${createdAt.hour.toString().padLeft(2, '0')}:'
        '${createdAt.minute.toString().padLeft(2, '0')}';

    if (useFontProvider) {
      return Consumer<FontProvider>(
        builder: (context, fontProvider, child) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 왼쪽: 작성 시간
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[500]),
                SizedBox(width: 4),
                Text(
                  timeString,
                  style: fontProvider.getTextStyle(
                    customSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),

            Flexible(
              child: DiaryTagsRow(
                weather: weather,
                emotion: emotion,
                socialContext: socialContext,
                activityType: activityType,
              ),
            ),
          ],
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 왼쪽: 작성 시간
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey[500]),
              SizedBox(width: 4),
              Text(
                timeString,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),

          // 오른쪽: 태그들 (Flexible로 감싸서 overflow 방지)
          Flexible(
            child: DiaryTagsRow(
              weather: weather,
              emotion: emotion,
              socialContext: socialContext,
              activityType: activityType,
            ),
          ),
        ],
      );
    }
  }
}
