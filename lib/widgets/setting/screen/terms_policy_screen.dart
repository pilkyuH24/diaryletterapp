// lib/screen/terms_policy_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';

class TermsPolicyScreen extends StatefulWidget {
  const TermsPolicyScreen({Key? key}) : super(key: key);

  @override
  State<TermsPolicyScreen> createState() => _TermsPolicyScreenState();
}

class _TermsPolicyScreenState extends State<TermsPolicyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          '약관 및 정책',
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: themeProv.colors.textPrimary,
          unselectedLabelColor: themeProv.colors.textSecondary,
          indicatorColor: themeProv.colors.textPrimary,
          labelStyle: TextStyle(
            fontFamily: 'OngeulipKonKonche',
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(text: '이용약관'),
            Tab(text: '개인정보처리방침'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTermsOfService(themeProv),
          _buildPrivacyPolicy(themeProv),
        ],
      ),
    );
  }

  Widget _buildTermsOfService(ThemeProvider themeProv) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildHeader('이용약관', '최종 업데이트: 2025년 8월 6일', themeProv),
        const SizedBox(height: 24),
        _buildSection(
          '제1조 (목적)',
          '본 약관은 일기편지 애플리케이션(이하 "서비스")의 이용조건 및 절차, 개발자와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.',
          themeProv,
        ),
        _buildSection(
          '제2조 (정의)',
          '1. "서비스"란 개발자가 제공하는 일기편지 모바일 애플리케이션 서비스를 의미합니다.\n\n2. "이용자"란 본 약관에 따라 서비스를 이용하는 사용자를 의미합니다.\n\n3. "일기"란 이용자가 서비스를 통해 작성하는 텍스트, 감정, 날씨, 활동 정보 등을 의미합니다.\n\n4. "AI 편지"란 인공지능이 이용자의 일기를 분석하여 생성하는 맞춤형 편지를 의미합니다.',
          themeProv,
        ),
        _buildSection(
          '제3조 (약관의 효력 및 변경)',
          '1. 본 약관은 서비스 이용자에게 공시함으로써 효력이 발생합니다.\n\n2. 개발자는 필요한 경우 본 약관을 변경할 수 있으며, 변경 시 애플리케이션을 통해 공지합니다.\n\n3. 변경된 약관에 동의하지 않는 경우 서비스 이용을 중단할 수 있습니다.',
          themeProv,
        ),
        _buildSection(
          '제4조 (서비스의 제공)',
          '1. 개발자는 다음과 같은 서비스를 제공합니다:\n   • 개인 일기 작성 및 관리\n   • 감정, 날씨, 활동, 사회적 상황 기록\n   • AI 기반 맞춤형 편지 생성\n   • 편지 보관함 및 히스토리 관리\n   • 테마 및 폰트 개인화\n   • 일기 작성 리마인더 알림\n\n2. 서비스는 연중무휴, 1일 24시간 제공을 원칙으로 하나, 기술적 한계로 인한 일시적 중단이 있을 수 있습니다.\n\n3. 개발자는 시스템 점검 등을 위해 서비스를 일시 중단할 수 있으며, 사전에 공지하도록 노력합니다.',
          themeProv,
        ),
        _buildSection(
          '제5조 (회원가입)',
          '1. 이용자는 다음 방법 중 하나로 회원가입을 할 수 있습니다:\n   • 이메일과 비밀번호를 이용한 회원가입\n   • 구글 소셜 로그인\n   • 애플 소셜 로그인\n\n2. 개발자는 다음 각 호의 신청에 대하여는 승낙을 하지 않을 수 있습니다:\n   • 허위 정보를 기재한 경우\n   • 기타 기술적 또는 정책적 사유로 서비스 제공이 어려운 경우',
          themeProv,
        ),
        _buildSection(
          '제6조 (이용자의 의무)',
          '1. 이용자는 다음 행위를 하여서는 안 됩니다:\n   • 허위 정보 등록 또는 타인의 정보 도용\n   • 서비스의 안정적 운영을 방해하는 행위\n   • 불법적이거나 부적절한 내용의 일기 작성\n   • 서비스를 상업적 목적으로 악용하는 행위\n\n2. 이용자는 관계법령과 본 약관의 규정을 준수하여야 합니다.',
          themeProv,
        ),
        _buildSection(
          '제7조 (서비스의 중단)',
          '개발자는 다음과 같은 경우 서비스 제공을 중단할 수 있습니다:\n\n• 시스템 점검, 업데이트, 보수 작업\n• 외부 서비스 제공업체(Supabase, Google AI 등)의 서비스 중단\n• 천재지변, 국가비상사태 등 불가항력적 사유\n• 서비스 이용량 급증으로 인한 시스템 과부하\n• 기타 기술적 사유로 서비스 제공이 어려운 경우',
          themeProv,
        ),
        _buildSection(
          '제8조 (면책조항)',
          '1. 개발자는 천재지변 또는 이에 준하는 불가항력으로 인하여 서비스를 제공할 수 없는 경우 책임이 면제됩니다.\n\n2. 개발자는 이용자의 귀책사유로 인한 서비스 이용의 장애에 대하여는 책임을 지지 않습니다.\n\n3. 개발자는 AI가 생성한 편지의 내용에 대해 완전성이나 정확성을 보장하지 않으며, 편지 내용으로 인한 문제에 대해 책임을 지지 않습니다.\n\n4. 개발자는 외부 서비스(Google AI API 등)의 정책 변경이나 중단으로 인한 서비스 제한에 대해 책임을 지지 않습니다.',
          themeProv,
        ),
        _buildSection(
          '제9조 (분쟁해결)',
          '1. 서비스 관련 문의사항이나 불만은 hpil331@gmail.com으로 연락주시기 바랍니다.\n\n2. 서비스 이용으로 발생한 분쟁에 대해 소송이 제기되는 경우 관할법원은 민사소송법에 따라 결정됩니다.',
          themeProv,
        ),
      ],
    );
  }

  Widget _buildPrivacyPolicy(ThemeProvider themeProv) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildHeader('개인정보처리방침', '최종 업데이트: 2025년 8월 6일', themeProv),
        const SizedBox(height: 24),
        _buildSection(
          '1. 개인정보의 처리목적',
          '일기편지는 다음의 목적을 위하여 개인정보를 처리합니다:\n\n• 회원 가입 및 본인 식별·인증\n• 일기 작성 및 저장 서비스 제공\n• AI 편지 생성 서비스 제공\n• 개인화된 사용자 경험 제공\n• 서비스 개선 및 고객 지원\n• 일기 작성 알림 등 맞춤형 서비스 제공',
          themeProv,
        ),
        _buildSection(
          '2. 처리하는 개인정보의 항목',
          '일기편지는 다음의 개인정보 항목을 처리합니다:\n\n회원정보\n• 이메일 주소 (필수)\n• 암호화된 비밀번호 (이메일 가입시)\n• 소셜 로그인 식별자 (소셜 로그인시)\n\n일기 관련 정보\n• 일기 제목 및 내용\n• 감정 상태 (행복, 슬픔, 화남, 불안, 설렘 등)\n• 날씨 정보 (맑음, 흐림, 비, 눈)\n• 사회적 상황 (혼자, 가족, 친구들, 연인)\n• 활동 유형 (일, 여가, 휴식, 운동, 자기계발, 여행, 일상)\n• 일기 작성 날짜 및 시간\n\nAI 서비스 관련\n• AI가 생성한 편지 내용\n• 편지 생성 이력\n\n앱 사용 정보\n• 테마 및 폰트 설정\n• 알림 설정\n• 앱 사용 통계 (개인 식별 불가능한 형태)',
          themeProv,
        ),
        _buildSection(
          '3. 개인정보의 처리 및 보유기간',
          '일기편지는 다음과 같이 개인정보를 처리·보유합니다:\n\n• 회원정보: 회원 탈퇴 시까지\n• 일기 및 편지 내용: 사용자가 직접 삭제하거나 회원 탈퇴 시까지\n• 앱 사용 설정: 회원 탈퇴 시까지\n\n단, 다음의 경우에는 해당 기간까지 보관합니다:\n• 관련 법령 위반에 따른 수사·조사 등이 진행 중인 경우: 해당 수사·조사 종료 시까지',
          themeProv,
        ),
        _buildSection(
          '4. 개인정보의 제3자 제공',
          '일기편지는 원칙적으로 개인정보를 제3자에게 제공하지 않습니다.\n\n다만, 다음의 경우에는 예외로 합니다:\n• 사용자가 사전에 동의한 경우\n• 법령의 규정에 의거하거나, 수사 목적으로 법령에 정해진 절차와 방법에 따라 수사기관의 요구가 있는 경우',
          themeProv,
        ),
        _buildSection(
          '5. 개인정보처리의 위탁',
          '일기편지는 원활한 서비스 제공을 위하여 다음과 같이 개인정보 처리업무를 위탁하고 있습니다:\n\n• Supabase Inc.\n  - 위탁 업무: 데이터 저장 및 사용자 인증\n  - 개인정보 보유기간: 위탁계약 종료시 또는 위탁목적 달성시까지\n\n• Google LLC\n  - 위탁 업무: AI 편지 생성 서비스\n  - 개인정보 보유기간: 편지 생성 즉시 삭제 (저장하지 않음)\n\n위탁업체들은 개인정보보호 관련 법령을 준수하며, 위탁목적 외 개인정보 처리를 금지하고 있습니다.',
          themeProv,
        ),
        _buildSection(
          '6. 정보주체의 권리·의무 및 그 행사방법',
          '사용자는 언제든지 다음과 같은 개인정보 보호 관련 권리를 행사할 수 있습니다:\n\n• 개인정보 열람 요구\n• 개인정보 정정·삭제 요구\n• 개인정보 처리정지 요구\n\n권리 행사는 다음 방법으로 가능합니다:\n• 앱 내 설정 메뉴를 통한 직접 수정/삭제\n• 이메일(hpil331@gmail.com)을 통한 요청\n\n요청 시 본인 확인 절차를 거치며, 법령에서 정한 기간 내에 처리해드립니다.',
          themeProv,
        ),
        _buildSection(
          '7. 개인정보의 안전성 확보조치',
          '일기편지는 개인정보 보호를 위해 다음과 같은 조치를 취하고 있습니다:\n\n기술적 조치\n• 개인정보 암호화 저장\n• 안전한 데이터 전송을 위한 SSL/TLS 적용\n• 해킹 방지를 위한 보안 프로그램 설치 및 점검\n\n관리적 조치\n• 개인정보 접근 권한의 최소화\n• 정기적인 보안 점검 및 업데이트\n• 개인정보 보호 정책 수립 및 시행\n\n물리적 조치\n• 안전한 클라우드 인프라 사용 (Supabase)\n• 데이터센터 물리적 보안 시설',
          themeProv,
        ),
        _buildSection(
          '8. 개인정보보호책임자',
          '일기편지의 개인정보 처리에 관한 업무를 총괄하는 개인정보보호책임자는 다음과 같습니다:\n\n개인정보보호책임자\n• 성명: 개발자\n• 이메일: hpil331@gmail.com\n\n개인정보보호와 관련한 문의사항, 불만처리, 피해구제 등에 관한 사항을 위 연락처로 문의해주시기 바랍니다. 신속하고 성실하게 답변드리겠습니다.',
          themeProv,
        ),
        _buildSection(
          '9. 개인정보 처리방침 변경',
          '이 개인정보처리방침은 2025년 8월 6일부터 적용됩니다.\n\n개인정보처리방침이 변경되는 경우 변경사항을 앱 내 공지사항을 통해 사전에 안내해드립니다.',
          themeProv,
        ),
      ],
    );
  }

  Widget _buildHeader(
    String title,
    String lastUpdated,
    ThemeProvider themeProv,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeProv.colors.primary.withOpacity(0.3),
            themeProv.colors.primary.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'OngeulipKonKonche',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: themeProv.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lastUpdated,
            style: TextStyle(
              fontFamily: 'OngeulipKonKonche',
              fontSize: 14,
              color: themeProv.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, ThemeProvider themeProv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'OngeulipKonKonche',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: themeProv.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'OngeulipKonKonche',
              fontSize: 14,
              height: 1.6,
              color: themeProv.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
