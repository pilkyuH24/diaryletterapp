// components/loading/error_state_widget.dart
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:flutter/material.dart';

class ErrorStateWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onReset;
  final ThemeProvider themeProv;
  final FontProvider fontProv;

  const ErrorStateWidget({
    Key? key,
    required this.errorMessage,
    required this.onRetry,
    required this.onReset,
    required this.themeProv,
    required this.fontProv,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLimit = errorMessage.contains('횟수를 모두 사용');
    final isDev = errorMessage.contains('개발 모드');
    final isNetwork =
        errorMessage.contains('인터넷') || errorMessage.contains('서버');

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getErrorColor(isLimit, isDev).withOpacity(0.1),
              ),
              child: Icon(
                _getErrorIcon(isLimit, isDev, isNetwork),
                size: 64,
                color: _getErrorColor(isLimit, isDev),
              ),
            ),
            SizedBox(height: 24),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: themeProv.colors.textSecondary,
                fontFamily: fontProv.fontFamily.isEmpty
                    ? null
                    : fontProv.fontFamily,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isLimit) ...[
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: Icon(Icons.refresh),
                    label: Text('다시 시도'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProv.colors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
                if (isLimit) ...[
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back),
                    label: Text('돌아가기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProv.colors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getErrorColor(bool isLimit, bool isDev) {
    if (isLimit) return Colors.orange[600]!;
    if (isDev) return Colors.blue[600]!;
    return Colors.red[400]!;
  }

  IconData _getErrorIcon(bool isLimit, bool isDev, bool isNetwork) {
    if (isLimit) return Icons.lock_clock;
    if (isDev) return Icons.build_circle_outlined;
    if (isNetwork) return Icons.wifi_off_outlined;
    return Icons.error_outline;
  }
}
