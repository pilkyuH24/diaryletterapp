import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/const/colors.dart';
import 'package:diaryletter/config/system_ui_config.dart'; // 🎨 상태바 설정 추가

/// 테마 설정 화면
class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({Key? key}) : super(key: key);

  @override
  _ThemeSettingsScreenState createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final fontProv = context.watch<FontProvider>();
    final themeProv = context.watch<ThemeProvider>();

    // 전체 폰트 목록에서 name만 뽑고, 중복 제거
    final allFonts = FontProvider.availableFonts;
    final uniqueNames = allFonts.map((f) => f['name']!).toSet().toList();

    // 현재 폰트 이름이 리스트에 없으면 null 처리
    final currentName = fontProv.getFontNameByFamily(fontProv.fontFamily);
    final dropdownValue = uniqueNames.contains(currentName)
        ? currentName
        : null;

    const sizes = [10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 22.0, 24.0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('테마 설정'),
        backgroundColor: themeProv.colors.surface,
      ),
      body: Container(
        color: themeProv.colors.surface,
        child: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'OngeulipKonKonche'),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // [1] 글꼴 및 글자 크기 설정
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeProv.colors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: themeProv.isDarkMode
                        ? Colors.grey.shade900
                        : Colors.white60,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '기본 글꼴',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<String>(
                      dropdownColor: themeProv.colors.background,
                      borderRadius: BorderRadius.circular(6),
                      isExpanded: true,
                      value: dropdownValue,
                      selectedItemBuilder: (context) {
                        return uniqueNames.map((name) {
                          final family = allFonts.firstWhere(
                            (f) => f['name'] == name,
                          )['family']!;
                          return Text(
                            name,
                            style: TextStyle(fontFamily: family, fontSize: 18),
                          );
                        }).toList();
                      },
                      items: uniqueNames.map((name) {
                        final family = allFonts.firstWhere(
                          (f) => f['name'] == name,
                        )['family']!;
                        return DropdownMenuItem<String>(
                          value: name,
                          child: Text(
                            name,
                            style: TextStyle(fontFamily: family, fontSize: 18),
                          ),
                        );
                      }).toList(),
                      onChanged: (name) {
                        if (name == null) return;
                        final family = fontProv.getFontFamilyByName(name);
                        fontProv.setFontFamily(family);
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '글자 크기',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: sizes.map((s) {
                        final selected = fontProv.fontSize == s;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: selected
                                ? themeProv.colors.primary.withOpacity(0.6)
                                : (themeProv.isDarkMode
                                      ? Colors.grey.withOpacity(0.6)
                                      : Colors.white),
                            border: Border.all(
                              color: themeProv.isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => fontProv.setFontSize(s),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Text(
                                '${s.toInt()}pt',
                                style: TextStyle(
                                  fontSize: Platform.isAndroid ? 12 : 14,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: selected
                                      ? themeProv.colors.textPrimary
                                      : themeProv.colors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // [2] 색상 테마 + 다크모드
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeProv.colors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: themeProv.isDarkMode
                        ? Colors.grey.shade900
                        : Colors.white60,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '색상 테마',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      children: [
                        _buildThemeColorButton(
                          AppTheme.pink,
                          PRIMARY_PINK,
                          '분홍',
                          themeProv.current == AppTheme.pink,
                          themeProv,
                        ),
                        _buildThemeColorButton(
                          AppTheme.green,
                          PRIMARY_GREEN,
                          '연두',
                          themeProv.current == AppTheme.green,
                          themeProv,
                        ),
                        _buildThemeColorButton(
                          AppTheme.blue,
                          PRIMARY_BLUE,
                          '파랑',
                          themeProv.current == AppTheme.blue,
                          themeProv,
                        ),
                        _buildThemeColorButton(
                          AppTheme.peach,
                          PRIMARY_PEACH,
                          '피치',
                          themeProv.current == AppTheme.peach,
                          themeProv,
                        ),
                        _buildThemeColorButton(
                          AppTheme.black,
                          PRIMARY_BLACK,
                          '블랙',
                          themeProv.current == AppTheme.black,
                          themeProv,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Theme(
                      data: Theme.of(context).copyWith(
                        switchTheme: SwitchThemeData(
                          trackOutlineColor: MaterialStateProperty.resolveWith((
                            states,
                          ) {
                            return states.contains(MaterialState.selected)
                                ? Colors.black
                                : Colors.grey[300]!;
                          }),
                          overlayColor: MaterialStateProperty.all(
                            Colors.transparent,
                          ),
                        ),
                      ),
                      child: SwitchListTile(
                        value: themeProv.isDarkMode,
                        onChanged: (v) {
                          // 🎨 다크모드 변경과 함께 상태바도 업데이트
                          context.read<ThemeProvider>().toggleDarkMode(v);
                          // 상태바 즉시 업데이트
                          SystemUIConfig.setSystemUIOverlay(v);
                        },
                        activeColor: Colors.grey,
                        activeTrackColor: Colors.white24,
                        inactiveThumbColor: Colors.black87.withOpacity(0.8),
                        inactiveTrackColor: Colors.grey[300]!,
                        tileColor: themeProv.isDarkMode
                            ? themeProv.colors.surface
                            : BACKGROUND_COLOR,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('다크 모드'),
                        subtitle: const Text('앱 전체 어두운 테마'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeColorButton(
    AppTheme theme,
    Color color,
    String label,
    bool selected,
    ThemeProvider themeProv,
  ) {
    return GestureDetector(
      onTap: () => context.read<ThemeProvider>().setTheme(theme),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: selected ? color : color.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: selected
                  ? themeProv.colors.textPrimary
                  : themeProv.colors.textSecondary,
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
