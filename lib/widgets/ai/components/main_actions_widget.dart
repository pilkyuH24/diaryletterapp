import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/widgets/ai/components/action_card_widget.dart';

class MainActionsWidget extends StatelessWidget {
  final int letterCount;
  final bool isLoadingCount;
  final VoidCallback onLetterGenerate;
  final VoidCallback? onLetterHistory;

  const MainActionsWidget({
    Key? key,
    required this.letterCount,
    required this.isLoadingCount,
    required this.onLetterGenerate,
    this.onLetterHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final fontProv = context.watch<FontProvider>();
    final tc = themeProv.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주요 기능',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: tc.textPrimary,
            fontFamily: fontProv.fontFamily.isEmpty
                ? null
                : fontProv.fontFamily,
          ),
        ),
        SizedBox(height: 16),
        ActionCardWidget(
          icon: Icons.edit,
          title: '새 편지 생성',
          subtitle: '최근 일기를 분석해서 따뜻한 편지를 받아보세요',
          color: Colors.indigoAccent,
          onTap: onLetterGenerate,
        ),
        SizedBox(height: 12),
        ActionCardWidget(
          icon: Icons.library_books,
          title: '편지 보관함',
          subtitle: _getLetterBoxSubtitle(),
          color: Colors.deepOrangeAccent,
          onTap: letterCount > 0 ? onLetterHistory : null,
          badge: _getLetterBoxBadge(),
        ),
      ],
    );
  }

  String _getLetterBoxSubtitle() {
    if (isLoadingCount) {
      return '편지 개수를 확인하는 중...';
    } else if (letterCount > 0) {
      return '저장된 편지 $letterCount개를 확인해보세요';
    } else {
      return '아직 받은 편지가 없어요';
    }
  }

  String? _getLetterBoxBadge() {
    if (isLoadingCount) return null;
    return letterCount > 0 ? '$letterCount' : null;
  }
}
