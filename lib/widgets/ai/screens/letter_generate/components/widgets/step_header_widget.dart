// components/widgets/step_header_widget.dart
import 'package:flutter/material.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/providers/font_provider.dart';

class StepHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final ThemeProvider themeProv;
  final FontProvider fontProv;

  const StepHeaderWidget({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.themeProv,
    required this.fontProv,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProv.colors.textPrimary,
              fontFamily: fontProv.fontFamily.isEmpty
                  ? null
                  : fontProv.fontFamily,
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: themeProv.colors.textSecondary,
              fontFamily: fontProv.fontFamily.isEmpty
                  ? null
                  : fontProv.fontFamily,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
