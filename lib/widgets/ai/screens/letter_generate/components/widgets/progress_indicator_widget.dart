// components/widgets/progress_indicator_widget.dart
import 'package:flutter/material.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/providers/font_provider.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final ThemeProvider themeProv;
  final FontProvider fontProv;

  const ProgressIndicatorWidget({
    Key? key,
    required this.currentStep,
    required this.themeProv,
    required this.fontProv,
  }) : super(key: key);

  static const List<String> stepLabels = ['선택', '생성', '완성'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          for (int i = 0; i < stepLabels.length; i++) ...[
            _buildStepCircle(i),
            if (i < stepLabels.length - 1) Expanded(child: _buildStepLine(i)),
          ],
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step) {
    final isActive = currentStep >= step;
    final isCurrent = currentStep == step;
    final c = themeProv.colors;

    return Column(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? c.primary : Colors.grey[300],
            border: isCurrent ? Border.all(color: c.primary, width: 3) : null,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: c.primary.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isActive
                ? Icon(
                    step < currentStep ? Icons.check : Icons.circle,
                    color: Colors.white,
                    size: step < currentStep ? 20 : 8,
                  )
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          stepLabels[step],
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? (themeProv.isDarkMode
                      ? themeProv.colors.textSecondary.withOpacity(0.6)
                      : c.primary)
                : c.textPrimary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontFamily: fontProv.fontFamily.isEmpty
                ? null
                : fontProv.fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    final done = currentStep > step;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: 3,
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: done ? themeProv.colors.primary : Colors.grey[300],
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }
}
