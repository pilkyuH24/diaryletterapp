// lib/widgets/font_settings_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/const/colors.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';

class FontSettingsDialog {
  static Future<void> show(BuildContext context) {
    final fontProv = context.read<FontProvider>();
    final themeProv = context.read<ThemeProvider>();

    // 1) availableFonts 에서 family 리스트 추출
    final families = FontProvider.availableFonts
        .map((f) => f['family']!)
        .toList();
    // 2) 초기값 세팅: prov 에 저장된 family 가 리스트에 없으면 첫 번째로
    double tmpSize = fontProv.fontSize;
    String tmpFamily = fontProv.fontFamily;
    if (!families.contains(tmpFamily)) {
      tmpFamily = families.first;
    }

    return showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: themeProv.isDarkMode
                  ? DARK_PAPER_BACKGROUND
                  : PAPER_BACKGROUND,

              title: Text(
                '폰트 설정',
                style: TextStyle(fontFamily: 'OngeulipKonKonche'),
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 300,
                  maxWidth: 500,
                  minHeight: 300,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '미리보기',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'OngeulipKonKonche',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 140,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: themeProv.isDarkMode
                              ? themeProv.colors.surface
                              : const Color.fromARGB(255, 232, 224, 218),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '어둠 속 빛나는 별, 작은 희망의 조각. 밤하늘 수놓은 아름다움, 고요한 속삭임 들려오네.',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: tmpSize,
                            fontFamily: tmpFamily.isEmpty ? null : tmpFamily,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            '크기',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'OngeulipKonKonche',
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: TEXT_PRIMARY_COLOR,
                                inactiveTrackColor: TEXT_PRIMARY_COLOR
                                    .withOpacity(0.3),
                                thumbColor: TEXT_PRIMARY_COLOR,
                                overlayColor: TEXT_PRIMARY_COLOR.withOpacity(
                                  0.2,
                                ),
                                valueIndicatorColor: TEXT_PRIMARY_COLOR,
                                valueIndicatorTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              child: Slider(
                                min: 10,
                                max: 24,
                                divisions: 7,
                                value: tmpSize,
                                label: tmpSize.toStringAsFixed(0),
                                onChanged: (v) => setState(() => tmpSize = v),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '글꼴',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'OngeulipKonKonche',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButton<String>(
                              dropdownColor: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(6),
                              isExpanded: true,
                              // value 가 항상 families 안의 값이 되도록 보장
                              value: tmpFamily,
                              items: families.map((fam) {
                                final name = FontProvider.availableFonts
                                    .firstWhere(
                                      (f) => f['family'] == fam,
                                    )['name']!;
                                return DropdownMenuItem<String>(
                                  value: fam,
                                  child: Text(
                                    name,
                                    style: TextStyle(fontFamily: fam),
                                  ),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => tmpFamily = v);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    '취소',
                    style: TextStyle(color: themeProv.colors.textPrimary),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    fontProv.updateFontSettings(tmpSize, tmpFamily);
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    '확인',
                    style: TextStyle(color: themeProv.colors.textPrimary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
