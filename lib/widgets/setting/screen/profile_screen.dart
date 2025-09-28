// lib/screen/profile_screen.dart

import 'package:diaryletter/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/screen/auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  String? userEmail;
  String? userName;
  static const String _nameKey = 'user_name';

  // 🔥 이메일 토글 상태 추가
  bool _isEmailVisible = false;

  // 🆕 계정 삭제 경고 컨테이너 표시 상태 추가
  bool _showDeleteWarning = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();

    // 🔥 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose(); // 🔥 애니메이션 컨트롤러 해제
    super.dispose();
  }

  // 🔧 로컬 저장된 이름을 우선으로 불러오기
  void _loadUserInfo() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // 로컬에 저장된 이름 먼저 확인
      final prefs = await SharedPreferences.getInstance();
      final localName = prefs.getString(_nameKey);

      setState(() {
        userEmail = user.email;
        userName =
            localName ?? // 🔧 로컬 이름 우선
            user.userMetadata?['name'] ??
            user.email?.split('@').first ??
            '사용자';
      });
    }
  }

  // 🔧 이름 변경 함수
  Future<void> _updateUserName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, newName);
    setState(() {
      userName = newName;
    });
  }

  // 🔥 이메일 표시/숨김 토글 함수
  void _toggleEmailVisibility() {
    setState(() {
      _isEmailVisible = !_isEmailVisible;
    });

    if (_isEmailVisible) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
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
          '프로필',
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
          // 프로필 카드
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: themeProv.colors.background,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // 프로필 아바타
                CircleAvatar(
                  radius: 50,
                  backgroundColor: themeProv.colors.textSecondary.withOpacity(
                    0.1,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: themeProv.colors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                // 이름
                Text(
                  userName ?? '사용자',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: themeProv.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // 🔥 이메일 토글 섹션
                _buildEmailToggleSection(themeProv),

                const SizedBox(height: 16),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // 계정 관리 섹션
          _buildSection('계정 관리', [
            _buildProfileItem(
              icon: Icons.edit_outlined,
              title: '이름 변경',
              subtitle: '편지에 사용될 이름 변경',
              onTap: () => _showEditNameDialog(),
              themeProv: themeProv,
            ),
          ], themeProv),

          const SizedBox(height: 32),

          // 🆕 1단계: 잘 안보이는 계정 삭제 텍스트 버튼
          if (!_showDeleteWarning) ...[
            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showDeleteWarning = true;
                  });
                },
                child: Text(
                  '계정 삭제',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],

          // 🆕 2단계: 경고 컨테이너 (조건부 표시)
          if (_showDeleteWarning) ...[
            const SizedBox(height: 32),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '⚠️ 주의 필요',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                      // 닫기 버튼 추가
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showDeleteWarning = false;
                          });
                        },
                        icon: Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.red[700],
                        ),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '계정을 삭제하면 모든 일기와 편지가 영구적으로 삭제됩니다.',
                    style: TextStyle(fontSize: 14, color: Colors.red[600]),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.delete_forever, color: Colors.white),
                      label: Text(
                        '계정 삭제',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _showDeleteAccountDialog(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 🔥 이메일 토글 섹션 (새로 추가된 메서드)
  Widget _buildEmailToggleSection(ThemeProvider themeProv) {
    return Column(
      children: [
        // 토글 버튼
        InkWell(
          onTap: _toggleEmailVisibility,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: themeProv.colors.textSecondary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isEmailVisible ? Icons.visibility_off : Icons.visibility,
                  size: 16,
                  color: themeProv.colors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  _isEmailVisible ? '이메일 숨기기' : '이메일 보기',
                  style: TextStyle(
                    // fontFamily: 'OngeulipKonKonche',
                    fontSize: 12,
                    color: themeProv.colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 애니메이션으로 나타나는 이메일
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isEmailVisible ? null : 0,
          curve: Curves.easeInOut,
          child: _isEmailVisible
              ? FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: themeProv.colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: themeProv.colors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 16,
                          color: themeProv.colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            userEmail ?? '이메일 정보 없음',
                            style: TextStyle(
                              // fontFamily: 'OngeulipKonKonche',
                              fontSize: 14,
                              color: themeProv.colors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
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
            // fontFamily: 'OngeulipKonKonche',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: themeProv.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeProvider themeProv,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: themeProv.colors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: themeProv.colors.primary),
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
          color: themeProv.colors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  // 🔧 이름 변경 다이얼로그 - 실제 기능 구현
  void _showEditNameDialog() {
    final themeProv = Provider.of<ThemeProvider>(context, listen: false);
    final nameController = TextEditingController(text: userName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: themeProv.colors.background,
        title: Text(
          '이름 변경',
          style: TextStyle(
            fontSize: 18,
            color: themeProv.colors.textPrimary,
            // fontFamily: 'OngeulipKonKonche',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '사용할 이름을 입력해주세요.',
              style: TextStyle(
                fontSize: 14,
                color: themeProv.colors.textSecondary,
                // fontFamily: 'OngeulipKonKonche',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: '이름을 입력해주세요.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              // style: TextStyle(fontFamily: 'OngeulipKonKonche'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              '취소',
              style: TextStyle(
                fontSize: 16,
                color: themeProv.colors.textSecondary,
                // fontFamily: 'OngeulipKonKonche',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                await _updateUserName(newName);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '이름이 "$newName"으로 변경되었습니다.',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: SUCCESS_COLOR,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '이름을 입력해주세요.',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProv.colors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              '변경',
              style: TextStyle(
                fontSize: 16,
              ), // fontFamily: 'OngeulipKonKonche'),
            ),
          ),
        ],
      ),
    );
  }

  // 🔧 계정 삭제 다이얼로그 1
  void _showDeleteAccountDialog() {
    final themeProv = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: themeProv.colors.background,
        title: Text(
          '계정 삭제 안내',
          style: TextStyle(
            fontSize: 18,
            color: Colors.red[700],
            // fontFamily: 'OngeulipKonKonche',
          ),
        ),
        content: Text(
          '계정을 삭제하면 소중한 추억들이 영원히 사라집니다:\n\n• 그동안 써온 모든 일기\n• 마음을 담아 보낸 모든 편지\n• 소중한 계정 정보\n\n한번 삭제된 추억은 되돌릴 수 없습니다.\n정말로 계속 진행하시겠습니까?',
          style: TextStyle(
            fontSize: 16,
            color: themeProv.colors.textSecondary,
            // fontFamily: 'OngeulipKonKonche',
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              '취소',
              style: TextStyle(
                fontSize: 16,
                color: themeProv.colors.textPrimary,
                // fontFamily: 'OngeulipKonKonche',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showFinalConfirmDialog(); // 🔁 두 번째 확인 다이얼로그 호출
            },
            child: Text(
              '확인',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
                // fontFamily: 'OngeulipKonKonche',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFinalConfirmDialog() {
    final themeProv = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: themeProv.colors.background,
        title: Text(
          '정말로 탈퇴하시겠습니까?',
          style: TextStyle(
            fontSize: 18,
            color: Colors.red[800],
            // fontFamily: 'OngeulipKonKonche',
          ),
        ),
        content: Text(
          '한 번 삭제하면 복구할 수 없습니다.',
          style: TextStyle(
            fontSize: 16,
            color: themeProv.colors.textSecondary,
            // fontFamily: 'OngeulipKonKonche',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              '취소',
              style: TextStyle(
                fontSize: 16,
                color: themeProv.colors.textPrimary,
                // fontFamily: 'OngeulipKonKonche',
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteAccount(); // 🔥 최종 삭제 실행
            },
            child: Text(
              '삭제',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red[800],
                fontWeight: FontWeight.bold,
                // fontFamily: 'OngeulipKonKonche',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔧 계정 완전 삭제 (Authentication 포함)
  Future<void> _deleteAccount() async {
    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인이 필요합니다.', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      debugPrint('🗑️ [Profile] 계정 삭제 시작 - 사용자 ID: ${user.id}');

      // 1. 현재 사용자의 모든 일기 삭제 (RLS로 권한 관리)
      debugPrint('📔 [Profile] 일기 데이터 삭제 중...');
      final diaries = await supabase.from('diary').select('id');
      debugPrint('📔 [Profile] 삭제할 일기 개수: ${diaries.length}');
      for (final diary in diaries) {
        await supabase.from('diary').delete().eq('id', diary['id']);
      }

      // 2. 현재 사용자의 모든 편지 삭제 (RLS로 권한 관리)
      debugPrint('💌 [Profile] 편지 데이터 삭제 중...');
      final letters = await supabase.from('letters').select('id');
      debugPrint('💌 [Profile] 삭제할 편지 개수: ${letters.length}');
      for (final letter in letters) {
        await supabase.from('letters').delete().eq('id', letter['id']);
      }

      // 3. 로컬 데이터 삭제
      debugPrint('📱 [Profile] 로컬 데이터 삭제 중...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_nameKey);

      // 🔥 4. Supabase Auth 계정 완전 삭제 (선택적)
      debugPrint('🔐 [Profile] Authentication 계정 삭제 시도 중...');
      try {
        // RPC 함수가 존재하는 경우에만 호출
        await supabase.rpc('delete_user_account');
        debugPrint('✅ [Profile] Authentication 계정 삭제 완료');
      } catch (authError) {
        debugPrint('⚠️ [Profile] Authentication 삭제 실패 (데이터만 삭제됨): $authError');
        // RPC 함수가 없거나 권한이 없는 경우, 데이터만 삭제하고 로그아웃 진행
      }

      // 5. 로그아웃
      debugPrint('👤 [Profile] 로그아웃 중...');
      await supabase.auth.signOut();

      Navigator.pop(context); // 로딩 닫기

      debugPrint('✅ [Profile] 모든 데이터 삭제 완료');

      // 로그인 화면으로 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => AuthScreen()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '계정이 완전히 삭제되었습니다.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      debugPrint('❌ [Profile] 계정 삭제 중 오류: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '계정 삭제 중 오류: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }
}
