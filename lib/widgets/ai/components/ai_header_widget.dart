import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/const/theme_colors.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/providers/font_provider.dart';

class AIHeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final fontProv = context.watch<FontProvider>();
    final tc = themeProv.colors;

    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tc.primary.withOpacity(0.8),
            Colors.deepPurpleAccent[100]!.withOpacity(0.5),
            Colors.pink[100]!.withOpacity(0.5),
            Colors.orange[100]!.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        // 🆕 Border + Shadow 조합
        border: Border.all(color: Colors.white30, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: tc.textPrimary.withOpacity(0.28),
            blurRadius: 15,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildIcon(tc),
          SizedBox(width: 16),
          _buildContent(fontProv),
        ],
      ),
    );
  }

  Widget _buildIcon(ThemeColors tc) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: tc.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        Icons.auto_awesome,
        size: 32,
        color: const Color.fromARGB(255, 182, 64, 251),
      ),
    );
  }

  Widget _buildContent(FontProvider fontProv) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '당신의 일기가 \n편지가 되어 돌아왔어요',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: fontProv.fontFamily.isEmpty
                  ? null
                  : fontProv.fontFamily,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '당신의 마음을 이해하고 따뜻한 위로를 전해드려요',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontFamily: fontProv.fontFamily.isEmpty
                  ? null
                  : fontProv.fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
