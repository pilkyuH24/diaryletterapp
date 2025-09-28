// components/loading/loading_state_widget.dart
import 'package:flutter/material.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/providers/font_provider.dart';

class LoadingStateWidget extends StatelessWidget {
  final String userName;
  final AnimationController pulseAnimation;
  final ThemeProvider themeProv;
  final FontProvider fontProv;

  const LoadingStateWidget({
    Key? key,
    required this.userName,
    required this.pulseAnimation,
    required this.themeProv,
    required this.fontProv,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pulseAnimationTween = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: pulseAnimation, curve: Curves.easeInOut));

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: pulseAnimationTween,
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    themeProv.colors.primary.withOpacity(0.2),
                    themeProv.colors.primary.withOpacity(0.1),
                  ],
                ),
              ),
              child: Icon(
                Icons.auto_stories_outlined,
                size: 48,
                color: themeProv.colors.primary,
              ),
            ),
          ),
          SizedBox(height: 32),
          Text(
            '$userName님의 소중한 일기들을\n불러오고 있어요...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: themeProv.colors.textPrimary,
              fontWeight: FontWeight.w600,
              fontFamily: fontProv.fontFamily.isEmpty
                  ? null
                  : fontProv.fontFamily,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16),
          CircularProgressIndicator(
            color: themeProv.colors.primary,
            strokeWidth: 3,
          ),
        ],
      ),
    );
  }
}
