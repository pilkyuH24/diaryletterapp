// components/steps/letter_result_step.dart

import 'package:diaryletter/const/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/const/colors.dart';

class LetterResultStep extends StatelessWidget {
  final String? title;
  final String? content;
  final VoidCallback onSave;
  final VoidCallback onRegenerate;
  final ThemeProvider themeProv;
  final FontProvider fontProv;

  const LetterResultStep({
    Key? key,
    required this.title,
    required this.content,
    required this.onSave,
    required this.onRegenerate,
    required this.themeProv,
    required this.fontProv,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // current 테마와 다크 모드에 맞춘 색 구성
    final colors = themeProv.isDarkMode
        ? ThemeProvider.darkMap[themeProv.current]!
        : ThemeProvider.lightMap[themeProv.current]!;

    return Column(
      children: [
        _buildLetterHeader(colors),
        Expanded(child: _buildLetterContent(colors)),
        _buildActionButtons(colors),
      ],
    );
  }

  Widget _buildLetterHeader(ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(
            Icons.mail_outline,
            color: themeProv.isDarkMode ? Colors.white70 : colors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title ?? '편지',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
                fontFamily: fontProv.fontFamily.isEmpty
                    ? null
                    : fontProv.fontFamily,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterContent(ThemeColors colors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeProv.isDarkMode
            ? DARK_PAPER_BACKGROUND
            : colors.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Text(
          content ?? '',
          style: TextStyle(
            fontSize: 16,
            height: 1.8,
            color: colors.textPrimary,
            fontFamily: fontProv.fontFamily.isEmpty
                ? null
                : fontProv.fontFamily,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onRegenerate,
              icon: Icon(Icons.refresh, color: colors.textSecondary),
              label: Text(
                '다시 생성',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontFamily: fontProv.fontFamily.isEmpty
                      ? null
                      : fontProv.fontFamily,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onSave,
              icon: Icon(Icons.save, size: 20, color: Colors.white),
              label: Text(
                '편지 저장하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontProv.fontFamily.isEmpty
                      ? null
                      : fontProv.fontFamily,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
