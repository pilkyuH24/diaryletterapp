import 'package:diaryletter/widgets/ui/font_settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';

class LetterView extends StatelessWidget {
  final String letterContent;
  final String letterTitle;
  final VoidCallback? onRefresh; // 다시 받기 버튼 콜백
  final VoidCallback? onBack; // 뒤로가기 버튼 콜백

  const LetterView({
    Key? key,
    required this.letterTitle,
    required this.letterContent,
    this.onRefresh,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final fontProv = context.watch<FontProvider>();
    final tc = themeProv.colors;

    return Scaffold(
      appBar: onBack != null
          ? AppBar(
              title: Text(
                '편지',
                style: TextStyle(
                  color: tc.textPrimary,
                  fontFamily: fontProv.fontFamily.isEmpty
                      ? null
                      : fontProv.fontFamily,
                ),
              ),
              backgroundColor: tc.background,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: tc.textPrimary),
                onPressed: onBack,
              ),
              actions: [
                // ✅ 오른쪽에 나올 아이콘들은 여기
                IconButton(
                  padding: const EdgeInsets.only(right: 12.0),
                  icon: Icon(Icons.text_format, color: tc.textPrimary),
                  onPressed: () => FontSettingsDialog.show(context),
                ),
              ],
            )
          : null,
      backgroundColor: tc.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 편지 제목 + 날짜
            Container(
              padding: const EdgeInsets.all(18),
              color: tc.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    letterTitle,
                    style: TextStyle(
                      fontSize: fontProv.fontSize + 2,
                      fontWeight: FontWeight.w600,
                      color: tc.textPrimary,
                      fontFamily: fontProv.fontFamily.isEmpty
                          ? null
                          : fontProv.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DateTime.now().month}월 ${DateTime.now().day}일',
                    style: TextStyle(
                      fontSize: 12,
                      color: tc.textSecondary,
                      fontFamily: fontProv.fontFamily.isEmpty
                          ? null
                          : fontProv.fontFamily,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 편지 본문
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                letterContent,
                style: TextStyle(
                  color: tc.textPrimary,
                  fontSize: fontProv.fontSize,
                  height: 1.6,
                  fontFamily: fontProv.fontFamily.isEmpty
                      ? null
                      : fontProv.fontFamily,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 🔹 다시 받기 버튼
            if (onRefresh != null)
              Center(
                child: TextButton.icon(
                  onPressed: onRefresh,
                  icon: Icon(Icons.refresh, color: tc.textSecondary, size: 16),
                  label: Text(
                    '다시 받기',
                    style: TextStyle(
                      color: tc.textSecondary,
                      fontSize: 14,
                      fontFamily: fontProv.fontFamily.isEmpty
                          ? null
                          : fontProv.fontFamily,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
