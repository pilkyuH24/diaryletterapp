// lib/screen/settings_screen.dart (Updated with Notification Settings)

import 'package:diaryletter/config/system_ui_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:diaryletter/const/colors.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/widgets/setting/screen/theme_settings.dart';
import 'package:diaryletter/widgets/setting/screen/notification_settings_screen.dart';
import 'package:diaryletter/screen/auth_screen.dart';
import 'package:diaryletter/widgets/setting/screen/profile_screen.dart';
import 'package:diaryletter/widgets/setting/screen/help_screen.dart';
import 'package:diaryletter/widgets/setting/screen/about_screen.dart';
import 'package:diaryletter/widgets/setting/screen/terms_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final tc = themeProv.colors;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        systemOverlayStyle: SystemUIConfig.getStatusBarStyle(
          themeProv.isDarkMode,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          '설정',
          style: TextStyle(
            color: tc.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [tc.surface, tc.surface, tc.accent.withOpacity(0.8)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSection('계정 및 설정', [
              _buildSettingsItem(
                icon: Icons.person_outline,
                title: '계정 및 개인정보',
                subtitle: '프로필 관리 및 개인정보 설정',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                themeProv: themeProv,
              ),
              _buildSettingsItem(
                icon: Icons.palette_outlined,
                title: '테마',
                subtitle: '글꼴·색상·다크 모드',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ThemeSettingsScreen()),
                  );
                },
                themeProv: themeProv,
              ),
              // 🆕 알림 설정 추가
              _buildSettingsItem(
                icon: Icons.notifications_outlined,
                title: '알림',
                subtitle: '일기 작성 알림 및 푸시 알림 설정',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen(),
                    ),
                  );
                },
                themeProv: themeProv,
              ),
            ], themeProv),
            _buildSection('데이터', [
              _buildSettingsItem(
                icon: Icons.backup_outlined,
                title: '데이터 내보내기',
                subtitle: '데이터 파일로 받기',
                onTap: () {
                  _showComingSoonDialog(context, '데이터 내보내기');
                },
                themeProv: themeProv,
              ),
            ], themeProv),
            _buildSection('정보 및 지원', [
              _buildSettingsItem(
                icon: Icons.info_outline,
                title: 'ABOUT',
                subtitle: '앱 소개 및 크레딧',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                },
                themeProv: themeProv,
              ),
              _buildSettingsItem(
                icon: Icons.help_outline,
                title: '도움말 및 피드백',
                subtitle: '사용법 및 FAQ',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpScreen()),
                  );
                },
                themeProv: themeProv,
              ),
              _buildSettingsItem(
                icon: Icons.policy_outlined,
                title: '약관 및 정책',
                subtitle: '이용약관·개인정보처리방침',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TermsPolicyScreen(),
                    ),
                  );
                },
                themeProv: themeProv,
              ),
            ], themeProv),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
              child: ElevatedButton.icon(
                icon: Icon(Icons.logout, color: tc.textPrimary),
                label: Text(
                  '로그아웃',
                  style: TextStyle(
                    fontSize: 16,
                    color: tc.textPrimary,
                    // fontFamily: 'OngeulipKonKonche',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: tc.background,
                  backgroundColor: tc.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _showLogoutConfirmation(context),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// 로그아웃 확인 다이얼로그
  void _showLogoutConfirmation(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: themeProv.colors.background,
        title: Text(
          '로그아웃',
          style: TextStyle(fontSize: 18, color: themeProv.colors.textPrimary),
        ),
        content: Text(
          '정말 로그아웃 하시겠습니까?',
          style: TextStyle(fontSize: 16, color: themeProv.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // 취소
            child: Text(
              '취소',
              style: TextStyle(
                fontSize: 18,
                color: themeProv.colors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              // 1) 다이얼로그 닫기
              Navigator.of(ctx).pop();
              // 2) Supabase 로그아웃
              await Supabase.instance.client.auth.signOut();
              // 3) AuthScreen으로 이동 (이전 스택 모두 제거)
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
            child: Text(
              '확인',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// 개발 예정 기능 다이얼로그
  void _showComingSoonDialog(BuildContext context, String feature) {
    final themeProv = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: themeProv.colors.background,
        title: Text(
          '곧 출시 예정',
          style: TextStyle(fontSize: 18, color: themeProv.colors.textPrimary),
        ),
        content: Text(
          '$feature 기능이 곧 추가될 예정입니다.\n조금만 기다려 주세요!',
          style: TextStyle(fontSize: 16, color: themeProv.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              '확인',
              style: TextStyle(fontSize: 16, color: themeProv.colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<Widget> children,
    ThemeProvider themeProv,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            // fontFamily: 'OngeulipKonKonche',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: themeProv.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeProvider themeProv,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0), // 아이템 간 간격
      decoration: BoxDecoration(
        color: themeProv.colors.background,
        borderRadius: BorderRadius.circular(12), // 둥근 모서리
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: TEXT_SECONDARY_COLOR),
        title: Text(
          title,
          style: TextStyle(
            // fontFamily: 'OngeulipKonKonche',
            fontWeight: FontWeight.w600,
            color: themeProv.colors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            // fontFamily: 'OngeulipKonKonche',
            color: themeProv.colors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: themeProv.colors.textPrimary,
        ),
        onTap: onTap,
      ),
    );
  }
}
