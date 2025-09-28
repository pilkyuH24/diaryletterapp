// lib/widgets/diary_field_selector.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/const/colors.dart';
import 'package:diaryletter/const/diary_option.dart';
import 'package:diaryletter/const/theme_colors.dart';
// import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';

class DiaryFieldSelector extends StatelessWidget {
  final DiarySelections selections;
  final ValueChanged<DiarySelections> onChanged;

  const DiaryFieldSelector({
    Key? key,
    required this.selections,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final fontProv = context.watch<FontProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final tc = themeProv.colors;

    return InkWell(
      onTap: () => _showSelectionModal(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: (themeProv.isDarkMode
              ? DARK_SURFACE
              : (selections.isComplete ? PAPER_BUTTON_GOOD : PAPER_BUTTON_BAD)),
          borderRadius: BorderRadius.circular(12),
          // border: Border.all(color: themeProv.isDarkMode ? : Color.fromARGB(255, 221, 213, 208)),
        ),
        child: selections.isComplete
            ? _buildSelectedState(tc)
            : _buildEmptyState(tc),
      ),
    );
  }

  Widget _buildSelectedState(ThemeColors tc) {
    final vals = [
      selections.emotion,
      selections.weather,
      selections.socialContext,
      selections.activityType,
    ].where((v) => v.isNotEmpty).toList();

    return Row(
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (var v in vals)
              Image.asset(
                'assets/icons/${_categoryOf(v)}/$v.png',
                width: 24,
                height: 24,
              ),
          ],
        ),
        SizedBox(width: 12),
        // ← 이 Text를 Expanded로 감싸기
        Expanded(
          child: Text(
            '오늘 하루 기록 완료 ✨',
            style: TextStyle(
              color: tc.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(Icons.edit, color: tc.textSecondary, size: 16),
      ],
    );
  }

  Widget _buildEmptyState(ThemeColors tc) {
    return Row(
      children: [
        Icon(Icons.sentiment_satisfied_alt, color: tc.textSecondary, size: 22),
        SizedBox(width: 12),
        // ← 마찬가지로 Expanded로 감싸기
        Expanded(
          child: Text(
            '오늘 하루는 어땠나요?',
            style: TextStyle(
              fontFamily: 'OngeulipKonKonche',
              color: tc.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(Icons.arrow_forward_ios, color: tc.textSecondary, size: 16),
      ],
    );
  }

  void _showSelectionModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => DiarySelectionModal(
        initialSelections: selections,
        onSelectionChanged: onChanged,
      ),
    );
  }

  String _categoryOf(String value) {
    // value 값을 보고 폴더명을 리턴합니다.
    if (DiaryOptions.emotions.any((o) => o.value == value)) return 'emotion';
    if (DiaryOptions.weathers.any((o) => o.value == value)) return 'weather';
    if (DiaryOptions.socialContexts.any((o) => o.value == value)) {
      return 'people';
    }
    return 'activity';
  }
}

class DiarySelectionModal extends StatefulWidget {
  final DiarySelections initialSelections;
  final ValueChanged<DiarySelections> onSelectionChanged;

  const DiarySelectionModal({
    Key? key,
    required this.initialSelections,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  State<DiarySelectionModal> createState() => _DiarySelectionModalState();
}

class _DiarySelectionModalState extends State<DiarySelectionModal> {
  late DiarySelections _sel;

  @override
  void initState() {
    super.initState();
    _sel = widget.initialSelections;
  }

  @override
  Widget build(BuildContext context) {
    // final fontProv = context.watch<FontProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final tc = themeProv.colors;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: (themeProv.isDarkMode
          ? DARK_SURFACE
          : Colors.white), // 다이얼로그 배경
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // 헤더
            Row(
              children: [
                Text(
                  '상태 선택',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: tc.textPrimary,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: TEXT_HINT_COLOR),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16),

            // 본문
            Expanded(
              child: ClipRect(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 감정: 3열 그리드
                      _buildGrid(
                        options: DiaryOptions.emotions,
                        selectedValue: _sel.emotion,
                        onSelected: (v) =>
                            setState(() => _sel = _sel.copyWith(emotion: v)),
                        columns: 4,
                        category: 'emotion',
                        themeProv: themeProv,
                      ),

                      // 날씨: 4열 그리드
                      _buildGrid(
                        options: DiaryOptions.weathers,
                        selectedValue: _sel.weather,
                        onSelected: (v) =>
                            setState(() => _sel = _sel.copyWith(weather: v)),
                        columns: 4,
                        category: 'weather',
                        themeProv: themeProv,
                      ),

                      // 함께한 사람: 4열 그리드
                      _buildGrid(
                        options: DiaryOptions.socialContexts,
                        selectedValue: _sel.socialContext,
                        onSelected: (v) => setState(
                          () => _sel = _sel.copyWith(socialContext: v),
                        ),
                        columns: 4,
                        category: 'people',
                        themeProv: themeProv,
                      ),

                      // 활동: 4열 그리드 (한 줄 최대 4개)
                      _buildGrid(
                        options: DiaryOptions.activityTypes,
                        selectedValue: _sel.activityType,
                        onSelected: (v) => setState(
                          () => _sel = _sel.copyWith(activityType: v),
                        ),
                        columns: 4,
                        category: 'activity',
                        themeProv: themeProv,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            // 확인 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sel.isComplete
                    ? () {
                        widget.onSelectionChanged(_sel);
                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _sel.isComplete
                      ? Colors.green[600]
                      : Colors.grey[300],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '기록하기',
                  style: TextStyle(
                    color: _sel.isComplete ? Colors.white : TEXT_PRIMARY_COLOR,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid({
    required List<DiaryOption> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
    required int columns,
    required String category,
    required ThemeProvider themeProv,
  }) {
    // 카테고리별 제목 설정
    String title = '';
    switch (category) {
      case 'emotion':
        title = '감정';
        break;
      case 'weather':
        title = '날씨';
        break;
      case 'people':
        title = '함께한 사람';
        break;
      case 'activity':
        title = '활동';
        break;
    }

    // 감정은 3열이라 간격을 줄임
    double spacing = category == 'emotion' ? 8 : 12;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProv.isDarkMode ? DARK_SURFACE : LIGHT_GREY_COLOR,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 제목
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: themeProv.isDarkMode ? DARK_TEXT : TEXT_PRIMARY_COLOR,
            ),
          ),
          SizedBox(height: 12),

          // 그리드
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              // 🔥 명시적인 세로 높이 설정으로 텍스트 공간 보장
              mainAxisExtent: category == 'emotion' ? 75 : 70,
            ),
            itemCount: options.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final o = options[index];
              final sel = o.value == selectedValue;
              return _buildOptionButton(
                option: o,
                category: category,
                isSelected: sel,
                onTap: () => onSelected(o.value),
                themeProv: themeProv,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required DiaryOption option,
    required String category,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeProvider themeProv,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 🔥 가로폭에 비례한 폰트 크기 (공간 보장으로 다시 증가)
        final fontSize = (constraints.maxWidth * 0.15).clamp(10.0, 13.0);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            // 🔥 전체 높이를 사용하도록 설정
            height: constraints.maxHeight,
            child: Column(
              children: [
                // 🔥 아이콘 영역 - 살짝 줄인 크기
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isSelected ^ themeProv.isDarkMode)
                        ? TEXT_PRIMARY_COLOR.withOpacity(0.25)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected ? Colors.transparent : Colors.white38,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Image.asset(
                      'assets/icons/$category/${option.value}.png',
                      width: 28,
                      height: 28,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // 🔥 텍스트 영역 - 이제 충분한 공간 보장됨
                Expanded(
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.topCenter,
                    child: Text(
                      option.text,
                      textAlign: TextAlign.center,
                      maxLines: 2, // 🔥 다시 2줄 허용
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'OngeulipKonKonche',
                        fontSize: Platform.isIOS ? 14 : fontSize,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: isSelected
                            ? themeProv.colors.textPrimary
                            : themeProv.colors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
