// lib/widgets/auth/services/auth_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  /// 🍎 Apple Sign-In
  static Future<AuthResponse> signInWithApple() async {
    // 1) Apple Sign-In 가능 여부 확인
    final isAvailable = await SignInWithApple.isAvailable();
    if (!isAvailable) {
      throw Exception('Apple Sign-In을 사용할 수 없습니다.');
    }

    // 2) Apple 인증 요청
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final idToken = credential.identityToken;
    final authCode = credential.authorizationCode;
    if (idToken == null || authCode == null) {
      throw Exception('Apple 인증 토큰을 가져오지 못했습니다.');
    }

    // 3) Supabase에 토큰 전달하여 로그인
    final res = await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      accessToken: authCode,
    );

    final supaUser = res.user;
    // 4) 첫 로그인 시 이메일·이름을 프로필에 저장
    if (supaUser != null && credential.email != null) {
      final fullName = [
        credential.givenName,
        credential.familyName,
      ].where((s) => s != null && s.isNotEmpty).join(' ');

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(email: credential.email, data: {'full_name': fullName}),
      );
    }

    return res;
  }

  /// 🔵 Google Sign-In
  static Future<AuthResponse> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      scopes: ['email'],
      clientId: Platform.isIOS
          ? '231600643707-el7695217fulu6o4ajrkocnj5hrqtoej.apps.googleusercontent.com'
          : null,
      serverClientId:
          '231600643707-1k3ech50nkug99f8qiru35bta0vfpm0u.apps.googleusercontent.com',
    );

    final account = await googleSignIn.signIn();
    if (account == null) {
      throw Exception('구글 로그인이 취소되었습니다.');
    }

    final auth = await account.authentication;
    if (auth.idToken == null || auth.accessToken == null) {
      throw Exception('구글 인증 토큰을 가져오지 못했습니다.');
    }

    return await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: auth.idToken!,
      accessToken: auth.accessToken!,
    );
  }

  /// 📧 이메일 로그인
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// 📧 이메일 회원가입
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// 📤 로그아웃
  static Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  /// 👤 현재 사용자 세션 확인
  static Session? getCurrentSession() {
    return Supabase.instance.client.auth.currentSession;
  }

  /// 🔍 현재 사용자 정보
  static User? getCurrentUser() {
    return Supabase.instance.client.auth.currentUser;
  }

  /// ❌ 에러 메시지 파싱
  static String parseAuthError(String error) {
    if (error.contains('Invalid login credentials')) {
      return '이메일 또는 비밀번호가 잘못되었습니다.';
    }
    if (error.contains('User already registered')) {
      return '이미 가입된 이메일입니다.';
    }
    if (error.contains('weak_password')) {
      return '비밀번호가 너무 약합니다.';
    }
    if (error.contains('invalid_email')) {
      return '올바른 이메일 주소를 입력해주세요.';
    }
    if (error.contains('UserCancel') || error.contains('cancelled')) {
      return '로그인이 취소되었습니다.';
    }
    return '로그인 중 오류가 발생했습니다.';
  }

  /// ✅ 이메일 유효성 검사
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// ✅ 비밀번호 유효성 검사
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
}
