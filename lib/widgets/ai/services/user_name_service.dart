import 'package:diaryletter/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diaryletter/providers/font_provider.dart';

class UserNameService {
  static const String _nameKey = 'user_name';

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  Future<String?> ensureUserName(BuildContext context) async {
    final currentName = await getUserName();

    if (currentName != null && currentName.trim().isNotEmpty) {
      return currentName;
    }

    final userName = await _showNameDialog(context);
    if (userName == null || userName.trim().isEmpty) {
      return null;
    }

    await setUserName(userName.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$userName님, 이름이 설정되었어요! 이제 편지를 받아보세요!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );

    return userName.trim();
  }

  Future<String?> _showNameDialog(BuildContext context) async {
    final controller = TextEditingController();
    final fontProv = context.read<FontProvider>();
    final themeProv = context.read<ThemeProvider>();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: themeProv.colors.secondary,
        title: Text(
          '이름 설정',
          style: TextStyle(
            fontFamily: fontProv.fontFamily.isEmpty
                ? null
                : fontProv.fontFamily,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '편지 수취인의 이름을 입력해주세요.',
              style: TextStyle(
                fontSize: 14,
                fontFamily: fontProv.fontFamily.isEmpty
                    ? null
                    : fontProv.fontFamily,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '이름을 적어주세요',
                filled: true,
                fillColor: themeProv.colors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              style: TextStyle(
                fontFamily: fontProv.fontFamily.isEmpty
                    ? null
                    : fontProv.fontFamily,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(
                color: themeProv.colors.textPrimary,
                fontFamily: fontProv.fontFamily.isEmpty
                    ? null
                    : fontProv.fontFamily,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProv.colors.card,
            ),
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, name);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '이름을 입력해주세요!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }
            },
            child: Text(
              '설정',
              style: TextStyle(
                color: themeProv.colors.textPrimary,
                fontFamily: fontProv.fontFamily.isEmpty
                    ? null
                    : fontProv.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
