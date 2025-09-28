// components/widgets/diary_list_widget.dart
import 'package:flutter/material.dart';
import 'package:diaryletter/model/diary_model.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/widgets/diary/components/diary_tags_row.dart';

class DiaryListWidget extends StatelessWidget {
  final List<DiaryModel> availableDiaries;
  final List<DiaryModel> selectedDiaries;
  final Function(DiaryModel) onDiaryToggle;
  final ThemeProvider themeProv;
  final FontProvider fontProv;

  const DiaryListWidget({
    Key? key,
    required this.availableDiaries,
    required this.selectedDiaries,
    required this.onDiaryToggle,
    required this.themeProv,
    required this.fontProv,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (availableDiaries.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: availableDiaries.length,
      itemBuilder: (context, index) {
        final diary = availableDiaries[index];
        final isSel = selectedDiaries.contains(diary);
        return _buildDiaryItem(diary, isSel);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeProv.colors.primary.withOpacity(0.1),
            ),
            child: Icon(
              Icons.edit_note,
              size: 64,
              color: themeProv.colors.primary.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 24),
          Text(
            '아직 작성된 일기가 없어요',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProv.colors.textPrimary,
              fontFamily: fontProv.fontFamily.isEmpty
                  ? null
                  : fontProv.fontFamily,
            ),
          ),
          SizedBox(height: 12),
          Text(
            '최근 30일간의 일기를 분석해서\n따뜻한 편지를 만들어드려요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: themeProv.colors.textSecondary,
              fontFamily: fontProv.fontFamily.isEmpty
                  ? null
                  : fontProv.fontFamily,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.edit),
            label: Text('일기 쓰러 가기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProv.colors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryItem(DiaryModel diary, bool isSelected) {
    final c = themeProv.colors;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onDiaryToggle(diary),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? c.primary.withOpacity(0.1)
                  : themeProv.isDarkMode
                  ? c.card.withOpacity(0.8)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? c.primary : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? c.primary.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.05),
                  blurRadius: isSelected ? 12 : 8,
                  offset: Offset(0, isSelected ? 4 : 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildSelectionCheckbox(isSelected, c),
                SizedBox(width: 16),
                Expanded(child: _buildDiaryContent(diary, c)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCheckbox(bool isSelected, dynamic colors) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? colors.primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? colors.primary : Colors.grey[400]!,
          width: 2,
        ),
      ),
      child: isSelected
          ? Icon(Icons.check, color: Colors.white, size: 16)
          : null,
    );
  }

  Widget _buildDiaryContent(DiaryModel diary, dynamic colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${diary.date.month}/${diary.date.day}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: themeProv.isDarkMode
                      ? colors.textSecondary
                      : colors.primary,
                  fontFamily: fontProv.fontFamily.isEmpty
                      ? null
                      : fontProv.fontFamily,
                ),
              ),
            ),
            SizedBox(width: 8),
            DiaryTagsRow(
              weather: diary.weather,
              emotion: diary.emotion,
              socialContext: diary.socialContext,
              activityType: diary.activityType,
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          diary.title.isNotEmpty
              ? diary.title
              : '${diary.date.month}/${diary.date.day} 일기',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
            fontFamily: fontProv.fontFamily.isEmpty
                ? null
                : fontProv.fontFamily,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4),
        Text(
          diary.content,
          style: TextStyle(
            fontSize: 14,
            color: colors.textSecondary,
            fontFamily: fontProv.fontFamily.isEmpty
                ? null
                : fontProv.fontFamily,
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
