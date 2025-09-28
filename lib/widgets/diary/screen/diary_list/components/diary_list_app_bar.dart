import 'package:flutter/material.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/widgets/diary/screen/diary_list/components/diary_search_field.dart';
import 'package:diaryletter/widgets/diary/screen/diary_list/components/diary_search_filter.dart';

class DiaryListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearchMode;
  final bool hasFilter;
  final int totalDiaryCount;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final Function(String) onSearchSubmitted;
  final Function(String) onSearchChanged;
  final VoidCallback onSearchTap;
  final VoidCallback onClearTap;
  final VoidCallback onFilterTap;
  final dynamic themeColors;
  final FontProvider fontProvider;

  const DiaryListAppBar({
    Key? key,
    required this.isSearchMode,
    required this.hasFilter,
    required this.totalDiaryCount,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchSubmitted,
    required this.onSearchChanged,
    required this.onSearchTap,
    required this.onClearTap,
    required this.onFilterTap,
    required this.themeColors,
    required this.fontProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: isSearchMode
          ? DiarySearchField(
              controller: searchController,
              focusNode: searchFocusNode,
              onSearchSubmitted: onSearchSubmitted,
              onSearchChanged: onSearchChanged,
              themeColors: themeColors,
              fontProvider: fontProvider,
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '일기 목록',
                  style: TextStyle(
                    color: themeColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontProvider.fontFamily.isEmpty
                        ? null
                        : fontProvider.fontFamily,
                  ),
                ),
                if (totalDiaryCount > 0)
                  Text(
                    '총 ${totalDiaryCount}개의 일기',
                    style: TextStyle(
                      color: themeColors.textSecondary,
                      fontSize: 12,
                      fontFamily: fontProvider.fontFamily.isEmpty
                          ? null
                          : fontProvider.fontFamily,
                    ),
                  ),
              ],
            ),
      actions: [
        if (isSearchMode || hasFilter)
          IconButton(
            icon: Icon(Icons.clear, color: themeColors.textPrimary),
            onPressed: onClearTap,
          ),
        if (!isSearchMode)
          IconButton(
            icon: Icon(Icons.search, color: themeColors.textPrimary),
            onPressed: onSearchTap,
          ),
        IconButton(
          icon: Stack(
            children: [
              Icon(
                Icons.filter_list,
                color: hasFilter
                    ? themeColors.textPrimary
                    : themeColors.textPrimary,
              ),
              if (hasFilter)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(.8),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: onFilterTap,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
