// lib/widgets/auth/components/social_login_section.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:diaryletter/const/colors.dart';
import 'package:diaryletter/widgets/auth/components/auth_button.dart';

class SocialLoginSection extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onAppleLogin;
  final VoidCallback onGoogleLogin;

  const SocialLoginSection({
    Key? key,
    required this.isProcessing,
    required this.onAppleLogin,
    required this.onGoogleLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // 🍎 Apple Sign-In 버튼 (iOS에서만 표시)
          if (Platform.isIOS) ...[
            AuthButton(
              text: 'Apple로 로그인',
              onPressed: onAppleLogin,
              isLoading: isProcessing,
              icon: Image.asset(
                'assets/icons/brand/apple.png',
                width: 24,
                height: 24,
              ),
              foregroundColor: PRIMARY_BLACK,
              loadingColor: PRIMARY_BLACK,
            ),
            const SizedBox(height: 16.0),
          ],

          // 🔵 Google Sign-In 버튼
          AuthButton(
            text: '구글로 로그인',
            onPressed: onGoogleLogin,
            isLoading: isProcessing,
            icon: Image.asset(
              'assets/icons/brand/google.png',
              width: 24,
              height: 24,
            ),
            foregroundColor: PRIMARY_BLACK,
            loadingColor: PRIMARY_BLACK,
          ),
        ],
      ),
    );
  }
}
