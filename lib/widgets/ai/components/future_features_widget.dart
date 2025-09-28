import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/widgets/ai/components/action_card_widget.dart';

class FutureFeaturesWidget extends StatelessWidget {
  final Function(String) onFeatureTap;

  const FutureFeaturesWidget({Key? key, required this.onFeatureTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final fontProv = context.watch<FontProvider>();
    final tc = themeProv.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '곧 만나볼 기능들',
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
          icon: Icons.psychology_alt,
          title: '성격 심층 분석',
          subtitle: '일기 데이터를 기반으로 기질과 성격을 정밀 분석해드려요',
          color: Colors.indigo,
          onTap: () => onFeatureTap('성격 심층 분석'),
          badge: '준비중',
          isDisabled: true,
        ),
        SizedBox(height: 12),
        ActionCardWidget(
          icon: Icons.people_outline,
          title: '인간관계 인사이트',
          subtitle: '친구, 연인과의 궁합 분석과 소통 팁을 알려드려요',
          color: Colors.deepOrange,
          onTap: () => onFeatureTap('인간관계 인사이트'),
          badge: '준비중',
          isDisabled: true,
        ),
      ],
    );
  }
}
