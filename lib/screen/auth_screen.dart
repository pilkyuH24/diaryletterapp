// lib/widgets/auth/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:diaryletter/const/colors.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/screen/main_screen.dart';
import 'package:diaryletter/widgets/auth/components/social_login_section.dart';
import 'package:diaryletter/widgets/auth/components/email_login_section.dart';
import 'package:diaryletter/widgets/auth/components/auth_button.dart';
import 'package:diaryletter/widgets/auth/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoading = true;
  bool isEmailMode = false;
  bool isSignUpMode = false;
  bool isProcessing = false;
  bool agreedToTerms = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCurrentSession();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _checkCurrentSession() async {
    try {
      await Future.delayed(const Duration(seconds: 1)); // 강제 로딩 시간
      final session = AuthService.getCurrentSession();
      if (!mounted) return;

      if (session != null) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen()));
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // authTheme 정의
    final tc = ThemeProvider.staticBlackLight;
    final colorScheme = ColorScheme.light(
      primary: tc.primary,
      onPrimary: tc.textPrimary,
      secondary: tc.secondary,
      onSecondary: tc.textPrimary,
      background: tc.background,
      onBackground: tc.textPrimary,
      surface: tc.surface,
      onSurface: tc.textPrimary,
      error: ERROR_COLOR,
      onError: tc.textPrimary,
    );
    final authTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.white,
      cardColor: tc.surface,
      fontFamily: 'OngeulipKonKonche',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: tc.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: tc.textPrimary),
      ),
    );

    return Theme(
      data: authTheme,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: screenHeight * 0.15),
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.7,
                    child: Image.asset('assets/img/new_logo.png'),
                  ),
                ),
                const SizedBox(height: 24.0),

                // 로딩 중이면 버튼 숨기기, 완료되면 로그인 UI 표시
                if (!isLoading) ...[
                  if (isEmailMode) ...[
                    // 📧 이메일 로그인 섹션
                    EmailLoginSection(
                      isSignUpMode: isSignUpMode,
                      isProcessing: isProcessing,
                      agreedToTerms: agreedToTerms,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      onBack: _handleBack,
                      onToggleMode: _handleToggleMode,
                      onSubmit: _handleEmailAuth,
                      onTermsChanged: (value) =>
                          setState(() => agreedToTerms = value),
                    ),
                  ] else ...[
                    // 🔗 소셜 로그인 섹션
                    SocialLoginSection(
                      isProcessing: isProcessing,
                      onAppleLogin: _handleAppleLogin,
                      onGoogleLogin: _handleGoogleLogin,
                    ),
                    const SizedBox(height: 24.0),

                    // 📧 이메일 로그인 버튼
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: AuthButton(
                        text: '이메일로 로그인',
                        onPressed: () => setState(() => isEmailMode = true),
                        icon: const Icon(
                          Icons.email_outlined,
                          size: 24,
                          color: PRIMARY_BLACK,
                        ),
                        foregroundColor: PRIMARY_BLACK,
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔙 뒤로가기 처리
  void _handleBack() {
    setState(() {
      isEmailMode = false;
      isSignUpMode = false;
      agreedToTerms = false;
      _clearForm();
    });
  }

  // 🔄 로그인/회원가입 모드 전환
  void _handleToggleMode() {
    setState(() {
      isSignUpMode = !isSignUpMode;
      agreedToTerms = false;
      _clearForm();
    });
  }

  // 🧹 폼 클리어
  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  // 🍎 Apple 로그인 처리
  Future<void> _handleAppleLogin() async {
    if (isProcessing) return;
    setState(() => isProcessing = true);

    try {
      await AuthService.signInWithApple();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen()));
    } catch (e) {
      debugPrint('Apple 로그인 에러: $e');
      _showSnackBar(AuthService.parseAuthError(e.toString()));
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  // 🔵 Google 로그인 처리
  Future<void> _handleGoogleLogin() async {
    if (isProcessing) return;
    setState(() => isProcessing = true);

    try {
      await AuthService.signInWithGoogle();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen()));
    } catch (e) {
      debugPrint('Google 로그인 에러: $e');
      _showSnackBar(AuthService.parseAuthError(e.toString()));
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  // 📧 이메일 로그인/회원가입 처리
  Future<void> _handleEmailAuth() async {
    if (isProcessing) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    // 유효성 검사
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('이메일과 비밀번호를 입력해주세요.');
      return;
    }
    if (!AuthService.isValidEmail(email)) {
      _showSnackBar('올바른 이메일 형식을 입력해주세요.');
      return;
    }
    if (!AuthService.isValidPassword(password)) {
      _showSnackBar('비밀번호는 6자 이상이어야 합니다.');
      return;
    }
    if (isSignUpMode && password != confirm) {
      _showSnackBar('비밀번호가 일치하지 않습니다.');
      return;
    }
    if (isSignUpMode && !agreedToTerms) {
      _showSnackBar('이용약관에 동의해주세요.');
      return;
    }

    setState(() => isProcessing = true);

    try {
      if (isSignUpMode) {
        final res = await AuthService.signUpWithEmail(
          email: email,
          password: password,
        );
        if (res.session != null) {
          if (!mounted) return;
          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen()));
        } else {
          _showSnackBar('회원가입이 완료되었습니다. 이메일을 확인해주세요.');
          setState(() {
            isSignUpMode = false;
            _clearForm();
          });
        }
      } else {
        await AuthService.signInWithEmail(email: email, password: password);
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen()));
      }
    } catch (e) {
      debugPrint('이메일 인증 에러: $e');
      _showSnackBar(AuthService.parseAuthError(e.toString()));
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  // 📢 스낵바 표시
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
