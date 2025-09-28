import 'package:diaryletter/model/diary_filter.dart';
import 'package:flutter/material.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/widgets/diary/screen/diary_list/components/diary_search_filter.dart';

class FilterChipWidget extends StatelessWidget {
  final DiaryFilter currentFilter;
  final VoidCallback onClear;
  final dynamic themeColors;
  final FontProvider fontProvider;

  const FilterChipWidget({
    Key? key,
    required this.currentFilter,
    required this.onClear,
    required this.themeColors,
    required this.fontProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: themeColors.background.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: themeColors.textSecondary.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 16,
                    color: themeColors.textSecondary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentFilter.description,
                      style: TextStyle(
                        color: themeColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: fontProvider.fontFamily.isEmpty
                            ? null
                            : fontProvider.fontFamily,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: themeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
