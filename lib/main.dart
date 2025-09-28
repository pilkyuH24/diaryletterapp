import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:diaryletter/screen/auth_screen.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/providers/notification_provider.dart';
import 'package:diaryletter/widgets/setting/services/notification_service.dart';
import 'package:diaryletter/managers/app_lifecycle_manager.dart';
import 'package:diaryletter/widgets/ads/reward_ad_service.dart';
import 'package:diaryletter/config/ad_config.dart';
import 'package:diaryletter/config/system_ui_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    _logInfo('🚀 앱 초기화 시작');

    // 📱 세로 모드 고정
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,

      // DeviceOrientation.landscapeLeft,
      // DeviceOrientation.landscapeRight,
    ]);

    // 🎨 초기 상태바 설정
    SystemUIConfig.setSystemUIOverlay(false);

    // 📱 기본 프로바이더 초기화
    final fontProv = FontProvider();
    await fontProv.initialize();
    final themeProv = ThemeProvider();
    await themeProv.initialize();

    // 🔔 알림 초기화
    final notificationService = NotificationService();
    await notificationService.initialize();
    final notificationProv = NotificationProvider();
    await notificationProv.initialize();

    // 📢 광고 초기화 (Android에서만, AdConfig 설정이 활성화된 경우에만)
    TrackingStatus? attStatus;
    if (AdConfig.isAdEnabled && Platform.isAndroid) {
      attStatus = await _initializeAds();
    } else if (Platform.isIOS) {
      _logInfo('🍎 iOS - 광고 비활성화됨');
    }

    // 🗄️ Supabase 초기화
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );

    // 📅 날짜 포맷 한국어 설정
    await initializeDateFormatting();

    _logInfo(
      '✅ 초기화 완료 ${AdConfig.isAdEnabled && Platform.isAndroid
          ? "(광고: ${_getATTStatusEmoji(attStatus)})"
          : Platform.isIOS
          ? "(광고 비활성화)"
          : ""}',
    );

    // 🚀 앱 실행
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<FontProvider>.value(value: fontProv),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProv),
          ChangeNotifierProvider<NotificationProvider>.value(
            value: notificationProv,
          ),
        ],
        child: const AppLifecycleManager(child: MyApp()),
      ),
    );
  } catch (e, stackTrace) {
    _handleInitializationError(e, stackTrace);
  }
}

/// 📢 광고 초기화 (Android에서만 실행)
Future<TrackingStatus?> _initializeAds() async {
  // 🔧 iOS에서는 절대 실행되지 않도록 이중 체크
  if (Platform.isIOS) {
    _logInfo('🍎 iOS에서 광고 초기화 건너뜀');
    return null;
  }

  TrackingStatus? attStatus;

  try {
    // 🧪 테스트 디바이스 등록
    if (AdConfig.shouldRegisterTestDevices) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: AdConfig.testDeviceIds),
      );
    }

    // 📢 AdMob 초기화 (Android에서만)
    await MobileAds.instance.initialize();
    RewardAdService.initialize();

    _logInfo('📢 광고 초기화 완료 (Android)');
  } catch (e) {
    _logInfo('⚠️ 광고 초기화 실패: $e');
  }

  return attStatus;
}

/// 🚨 초기화 실패 처리
void _handleInitializationError(Object e, StackTrace stackTrace) {
  debugPrint('❌ 초기화 실패: $e');
  if (kDebugMode) {
    debugPrint('📋 Stack trace: $stackTrace');
  }

  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                '앱 초기화에 실패했습니다',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '앱을 다시 시작해주세요',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// 로그 출력 (디버그 모드에서만)
void _logInfo(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}

/// ATT 상태 텍스트 변환
String _getATTStatusText(TrackingStatus status) {
  switch (status) {
    case TrackingStatus.authorized:
      return '광고 추적 허용';
    case TrackingStatus.denied:
      return '광고 추적 거부';
    case TrackingStatus.restricted:
      return '광고 추적 제한';
    case TrackingStatus.notDetermined:
      return '권한 미결정';
    case TrackingStatus.notSupported:
      return '기능 미지원';
  }
}

/// ATT 상태 이모지
String _getATTStatusEmoji(TrackingStatus? status) {
  if (status == null) return '❓';
  switch (status) {
    case TrackingStatus.authorized:
      return '✅';
    case TrackingStatus.denied:
      return '❌';
    case TrackingStatus.restricted:
      return '⚠️';
    case TrackingStatus.notDetermined:
      return '❓';
    case TrackingStatus.notSupported:
      return '🚫';
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final fontProv = context.watch<FontProvider>();
    final themeProv = context.watch<ThemeProvider>();

    // 🎨 테마 변경 시 상태바 자동 업데이트
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemUIConfig.setSystemUIOverlay(themeProv.isDarkMode);
    });

    return MaterialApp(
      // 🎨 테마 설정 - ThemeProvider에서 생성된 테마 사용
      theme: themeProv.getLightThemeWithFont(fontProv.fontFamily),
      darkTheme: themeProv.getDarkThemeWithFont(fontProv.fontFamily),
      themeMode: themeProv.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: const AuthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
