// lib/screen/help_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? expandedIndex;

  final List<FAQItem> faqItems = [
    FAQItem(
      question: '앱 사용이 처음인데 어떻게 시작하나요?',
      answer:
          '환영합니다! 달력과 일기 화면에서 "일기 쓰기"를 눌러 첫 일기를 작성해보세요. 일기를 쓰시고 AI화면에서 따뜻한 편지를 만들어드려요.',
      icon: Icons.rocket_launch_outlined,
    ),
    FAQItem(
      question: '일기와 편지는 계정 삭제 시 모두 삭제되나요?',
      answer: '네, 계정 삭제 시 모든 일기와 AI 편지는 영구 삭제되어 복구할 수 없습니다. 신중히 결정해 주세요.',
      icon: Icons.delete_outline,
    ),
    FAQItem(
      question: '알림 주기를 변경할 수 있나요?',
      answer:
          '네, 언제든지 가능합니다. 설정에서 일기 작성 리마인더 주기를 조정할 수 있습니다. 개인의 생활 패턴에 맞게 자유롭게 설정해보세요.',
      icon: Icons.edit_calendar_outlined,
    ),
    FAQItem(
      question: '오프라인에서도 사용할 수 있나요?',
      answer: '모든 기능은 인터넷 연결이 필요합니다. 오프라인에서는 일기 작성 및 AI 편지 생성이 불가능합니다.',
      icon: Icons.wifi_off_outlined,
    ),
    FAQItem(
      question: '편지는 어떻게 만들어지나요?',
      answer:
          '선택하신 일기들을 AI가 분석해서 감정 패턴과 경험을 파악한 후, 따뜻하고 개인화된 편지를 작성해드립니다. 여러 개의 일기를 선택하시면 더 풍부한 내용의 편지를 받을 수 있어요.',
      icon: Icons.auto_awesome_outlined,
    ),
  ];

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
          '도움말 및 피드백',
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
          // 헤더
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeProv.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.help_outline,
                  size: 48,
                  color: themeProv.colors.textPrimary,
                ),
                const SizedBox(height: 12),
                Text(
                  '자주 묻는 질문',
                  style: TextStyle(
                    fontFamily: 'OngeulipKonKonche',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: themeProv.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '궁금한 것이 있으신가요?\n아래에서 답을 찾아보세요.',
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
          const SizedBox(height: 24),

          // FAQ 리스트
          ...faqItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isExpanded = expandedIndex == index;

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
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      item.icon,
                      color: themeProv.colors.textPrimary,
                    ),
                    title: Text(
                      item.question,
                      style: TextStyle(
                        fontFamily: 'OngeulipKonKonche',
                        fontWeight: FontWeight.w600,
                        color: themeProv.colors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    trailing: AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: themeProv.colors.textSecondary,
                      ),
                    ),
                    onTap: () => setState(
                      () => expandedIndex = isExpanded ? null : index,
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: Container(),
                    secondChild: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        item.answer,
                        style: TextStyle(
                          fontFamily: 'OngeulipKonKonche',
                          fontSize: 14,
                          height: 1.5,
                          color: themeProv.colors.textSecondary,
                        ),
                      ),
                    ),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: Duration(milliseconds: 200),
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 32),

          // 이메일 문의 섹션
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProv.colors.primary.withOpacity(0.1),
                  themeProv.colors.primary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.mail_outline,
                  size: 32,
                  color: themeProv.colors.textPrimary,
                ),
                const SizedBox(height: 12),
                Text(
                  '더 도움이 필요하신가요?',
                  style: TextStyle(
                    fontFamily: 'OngeulipKonKonche',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: themeProv.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '원하는 답을 찾지 못하셨다면\n아래 이메일로 문의해 주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'OngeulipKonKonche',
                    fontSize: 14,
                    color: themeProv.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                // ★ 버튼 너비를 화면의 50%로 제한
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.email_outlined, color: Colors.white),
                    label: Text(
                      '이메일 문의',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: 'OngeulipKonKonche',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProv.colors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _showEmailDialog,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEmailDialog() {
    final themeProv = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: themeProv.colors.background,
        title: Text(
          '이메일 문의',
          style: TextStyle(fontSize: 18, color: themeProv.colors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.email_outlined,
              size: 48,
              color: themeProv.colors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'hpil331@gmail.com',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: themeProv.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '위 이메일로 문의주시면\n빠른 시간 내에 답변 드리겠습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: themeProv.colors.textSecondary,
              ),
            ),
          ],
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
}

class FAQItem {
  final String question;
  final String answer;
  final IconData icon;

  FAQItem({required this.question, required this.answer, required this.icon});
}
