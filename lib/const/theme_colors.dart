// lib/const/theme_colors.dart
import 'package:flutter/material.dart';

/// 테마별 색상 구성
class ThemeColors {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;

  const ThemeColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
  });

  get onSurface => null;
}
