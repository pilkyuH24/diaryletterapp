// lib/widgets/auth/components/email_login_section.dart

import 'package:flutter/material.dart';
import 'package:diaryletter/const/colors.dart';
import 'package:diaryletter/widgets/setting/screen/terms_policy_screen.dart';
import 'package:diaryletter/widgets/auth/components/auth_button.dart';

class EmailLoginSection extends StatelessWidget {
  final bool isSignUpMode;
  final bool isProcessing;
  final bool agreedToTerms;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onBack;
  final VoidCallback onToggleMode;
  final VoidCallback onSubmit;
  final ValueChanged<bool> onTermsChanged;

  const EmailLoginSection({
    Key? key,
    required this.isSignUpMode,
    required this.isProcessing,
    required this.agreedToTerms,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onBack,
    required this.onToggleMode,
    required this.onSubmit,
    required this.onTermsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: TEXT_PRIMARY_COLOR),
            label: const Text(
              '뒤로',
              style: TextStyle(color: TEXT_PRIMARY_COLOR),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isSignUpMode ? '회원가입' : '로그인',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: PRIMARY_BLACK,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // 이메일 입력
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: '이메일',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              prefixIcon: const Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 16),

          // 비밀번호 입력
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: '비밀번호',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              prefixIcon: const Icon(Icons.lock),
            ),
          ),

          // 회원가입 모드일 때만 표시
          if (isSignUpMode) ...[
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),

            // 약관 동의
            Row(
              children: [
                Checkbox(
                  checkColor: Colors.grey.shade400,
                  value: agreedToTerms,
                  onChanged: (v) => onTermsChanged(v ?? false),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TermsPolicyScreen(),
                      ),
                    ),
                    child: Text(
                      '이용약관 및 개인정보처리방침에 동의합니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // 로그인/회원가입 버튼
          AuthButton(
            text: isSignUpMode ? '회원가입' : '로그인',
            onPressed: onSubmit,
            isLoading: isProcessing,
            foregroundColor: PRIMARY_BLACK,
            loadingColor: PRIMARY_BLACK,
          ),

          const SizedBox(height: 16),

          // 모드 전환 버튼
          TextButton(
            onPressed: isProcessing ? null : onToggleMode,
            child: Text.rich(
              TextSpan(
                text: isSignUpMode ? '이미 계정이 있으신가요? ' : '계정이 없으신가요? ',
                style: const TextStyle(color: TEXT_PRIMARY_COLOR),
                children: [
                  TextSpan(
                    text: isSignUpMode ? '로그인' : '회원가입',
                    style: const TextStyle(
                      color: TEXT_PRIMARY_COLOR,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
