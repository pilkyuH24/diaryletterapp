import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/const/theme_colors.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/providers/font_provider.dart';

class ActionCardWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final String? badge;
  final bool isDisabled;

  const ActionCardWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
    this.badge,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final fontProv = context.watch<FontProvider>();
    final tc = themeProv.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: tc.background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDisabled
                    ? Colors.grey.withOpacity(0.1)
                    : color.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildIcon(),
              SizedBox(width: 16),
              _buildContent(tc, fontProv),
              _buildArrow(tc),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDisabled ? Colors.grey[200] : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: isDisabled ? Colors.grey[600] : color, size: 24),
    );
  }

  Widget _buildContent(ThemeColors tc, FontProvider fontProv) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDisabled ? Colors.grey[500] : tc.textPrimary,
                  fontFamily: fontProv.fontFamily.isEmpty
                      ? null
                      : fontProv.fontFamily,
                ),
              ),
              if (badge != null) ...[SizedBox(width: 8), _buildBadge(fontProv)],
            ],
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: isDisabled ? Colors.grey[400] : tc.textSecondary,
              fontFamily: fontProv.fontFamily.isEmpty
                  ? null
                  : fontProv.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(FontProvider fontProv) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isDisabled ? Colors.grey[300] : color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        badge!,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDisabled ? Colors.grey[600] : color,
          fontFamily: fontProv.fontFamily.isEmpty ? null : fontProv.fontFamily,
        ),
      ),
    );
  }

  Widget _buildArrow(ThemeColors tc) {
    return Icon(
      Icons.arrow_forward_ios,
      color: isDisabled ? Colors.grey[300] : tc.textSecondary,
      size: 16,
    );
  }
}
