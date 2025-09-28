// lib/screen/about_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'ABOUT',
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // 앱 로고 및 기본 정보
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProv.colors.primary.withOpacity(0.1),
                  themeProv.colors.primary.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // 앱 아이콘
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: themeProv.colors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: themeProv.colors.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    // child: Icon(Icons.psychology, size: 50, color: Colors.white),
                    child: Image.asset(
                      'assets/img/new_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                // 앱 이름
                Text(
                  '일기편지',
                  style: TextStyle(
                    fontFamily: 'OngeulipKonKonche',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: themeProv.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                // 버전 정보
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontFamily: 'OngeulipKonKonche',
                    fontSize: 16,
                    color: themeProv.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                // 앱 설명
                Text(
                  '일기가 편지가 되어 돌아오는 마음 치유 앱',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'OngeulipKonKonche',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: themeProv.colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 앱 소개
          _buildSection('앱 소개', [
            _buildInfoCard(
              icon: Icons.auto_awesome,
              title: 'AI 감정 분석',
              description: '일기 속 감정과 경험을 AI가 분석하여 따뜻한 편지와 개인 맞춤형 피드백을 제공합니다.',
              themeProv: themeProv,
            ),
            _buildInfoCard(
              icon: Icons.track_changes,
              title: '감정 변화 추적',
              description: '매일의 일기 기록을 통해 감정 패턴과 마음의 변화를 시각적으로 확인할 수 있습니다.',
              themeProv: themeProv,
            ),
            _buildInfoCard(
              icon: Icons.cloud_sync,
              title: '언제 어디서나',
              description: '클라우드 동기화로 스마트폰, 태블릿 어디서든 일기를 작성하고 편지를 받아볼 수 있어요.',
              themeProv: themeProv,
            ),
          ], themeProv),

          const SizedBox(height: 24),

          // 🆕 크레딧 정보
          _buildSection('크레딧', [
            _buildCreditItem(
              title: '아이콘',
              source: 'Flaticon',
              url: 'https://www.flaticon.com',
              description: 'Flaticon에서 제공하는 아이콘을 사용했습니다.',
              themeProv: themeProv,
            ),
          ], themeProv),

          const SizedBox(height: 24),

          // 🆕 개발팀 정보
          _buildSection('개발팀', [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeProv.colors.background,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: themeProv.colors.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.code,
                      size: 30,
                      color: themeProv.isDarkMode
                          ? themeProv.colors.textPrimary
                          : themeProv.colors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Mellow Studio',
                    style: TextStyle(
                      fontFamily: 'OngeulipKonKonche',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: themeProv.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 개발팀 설명
                  Text(
                    '사람에게 부드러운 기술을 만듭니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'OngeulipKonKonche',
                      fontSize: 14,
                      color: themeProv.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '마음을 돌보는 디지털 친구를 만듭니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'OngeulipKonKonche',
                      fontSize: 14,
                      color: themeProv.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ], themeProv),

          const SizedBox(height: 32),

          // 저작권 정보
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProv.colors.background.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '© 2025 Mellow Studio. All rights reserved.\n\n이 앱은 일상을 기록하고 AI와 소통하며 마음을 돌아보는 개인 일기장입니다. 깊은 고민이나 전문적인 도움이 필요한 경우 정신건강 전문가와 상담하시기 바랍니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'OngeulipKonKonche',
                fontSize: 12,
                color: themeProv.colors.textSecondary,
                height: 1.4,
              ),
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
        Text(
          title,
          style: TextStyle(
            fontFamily: 'OngeulipKonKonche',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: themeProv.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required ThemeProvider themeProv,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProv.colors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeProv.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 24,
              color: themeProv.isDarkMode
                  ? themeProv.colors.textPrimary
                  : themeProv.colors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'OngeulipKonKonche',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: themeProv.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'OngeulipKonKonche',
                    fontSize: 14,
                    color: themeProv.colors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditItem({
    required String title,
    required String source,
    required String url,
    required String description,
    required ThemeProvider themeProv,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: themeProv.colors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          Icons.attribution_outlined,
          color: themeProv.isDarkMode
              ? themeProv.colors.textPrimary
              : themeProv.colors.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'OngeulipKonKonche',
            fontWeight: FontWeight.w600,
            color: themeProv.colors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontFamily: 'OngeulipKonKonche',
                fontSize: 12,
                color: themeProv.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _launchURL(url),
              child: Text(
                source,
                style: TextStyle(
                  fontFamily: 'OngeulipKonKonche',
                  fontSize: 12,
                  color: themeProv.colors.textPrimary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.open_in_new,
          size: 16,
          color: themeProv.colors.textSecondary,
        ),
        onTap: () => _launchURL(url),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
