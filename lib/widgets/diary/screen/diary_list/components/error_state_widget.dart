import 'package:flutter/material.dart';
import 'package:diaryletter/providers/font_provider.dart';

class ErrorStateWidget extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;
  final dynamic themeColors;
  final FontProvider fontProvider;

  const ErrorStateWidget({
    Key? key,
    this.errorMessage,
    required this.onRetry,
    required this.themeColors,
    required this.fontProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: 24),
            Text(
              errorMessage ?? '오류가 발생했습니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: themeColors.textSecondary,
                fontFamily: fontProvider.fontFamily.isEmpty
                    ? null
                    : fontProvider.fontFamily,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh),
              label: Text(
                '다시 시도',
                style: TextStyle(
                  fontFamily: fontProvider.fontFamily.isEmpty
                      ? null
                      : fontProvider.fontFamily,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
