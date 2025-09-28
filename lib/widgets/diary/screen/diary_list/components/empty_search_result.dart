import 'package:diaryletter/model/diary_filter.dart';
import 'package:flutter/material.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/widgets/diary/screen/diary_list/components/diary_search_filter.dart';

class EmptySearchResult extends StatelessWidget {
  final bool isFilterMode;
  final DiaryFilter? currentFilter;
  final dynamic themeColors;
  final FontProvider fontProvider;

  const EmptySearchResult({
    Key? key,
    required this.isFilterMode,
    this.currentFilter,
    required this.themeColors,
    required this.fontProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              isFilterMode ? '필터 조건에 맞는 일기가 없어요' : '검색 결과가 없어요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: themeColors.textPrimary,
                fontFamily: fontProvider.fontFamily.isEmpty
                    ? null
                    : fontProvider.fontFamily,
              ),
            ),
            SizedBox(height: 8),
            Text(
              isFilterMode ? '다른 조건으로 필터링해보세요' : '다른 키워드로 검색해보세요',
              style: TextStyle(
                fontSize: 14,
                color: themeColors.textSecondary,
                fontFamily: fontProvider.fontFamily.isEmpty
                    ? null
                    : fontProvider.fontFamily,
              ),
            ),
            if (isFilterMode && currentFilter != null) ...[
              SizedBox(height: 16),
              Text(
                '현재 필터: ${currentFilter!.description}',
                style: TextStyle(
                  fontSize: 12,
                  color: themeColors.primary,
                  fontFamily: fontProvider.fontFamily.isEmpty
                      ? null
                      : fontProvider.fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
