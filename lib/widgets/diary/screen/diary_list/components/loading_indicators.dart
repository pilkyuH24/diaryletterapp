import 'package:flutter/material.dart';

class LoadingIndicators {
  static Widget center(dynamic themeColors, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: themeColors.primary),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: themeColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  static Widget bottom(dynamic themeColors) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: themeColors.primary,
                strokeWidth: 2,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '더 많은 일기 불러오는 중...',
              style: TextStyle(fontSize: 12, color: themeColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
