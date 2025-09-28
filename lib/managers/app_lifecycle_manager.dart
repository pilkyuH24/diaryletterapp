// lib/managers/app_lifecycle_manager.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/providers/notification_provider.dart';

/// 앱 생명주기를 관리하고 포그라운드 진입 시 뱃지를 자동으로 클리어하는 위젯
class AppLifecycleManager extends StatefulWidget {
  final Widget child;

  const AppLifecycleManager({Key? key, required this.child}) : super(key: key);

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager>
    with WidgetsBindingObserver {
  // 🔥 중복 호출 방지를 위한 변수들
  bool _isProcessingBadgeClear = false;
  DateTime? _lastBadgeClearTime;

  @override
  void initState() {
    super.initState();
    debugPrint('🔄 [AppLifecycleManager] 초기화 시작');

    // 앱 생명주기 옵저버 등록
    WidgetsBinding.instance.addObserver(this);

    // 앱 시작 시에도 뱃지 클리어 (다음 프레임에서 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearBadgeOnAppStart();
    });

    debugPrint('✅ [AppLifecycleManager] 초기화 완료');
  }

  @override
  void dispose() {
    debugPrint('🔄 [AppLifecycleManager] 종료 중...');

    // 옵저버 해제
    WidgetsBinding.instance.removeObserver(this);

    debugPrint('✅ [AppLifecycleManager] 종료 완료');
    super.dispose();
  }

  /// 앱 상태 변화 감지
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    debugPrint('📱 [AppLifecycleManager] 앱 상태 변화: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        // 🔥 앱이 포그라운드로 돌아왔을 때 - 뱃지 클리어! (중복 방지)
        debugPrint('🌟 [AppLifecycleManager] 앱 포그라운드 진입 감지!');
        _clearBadgeOnResume();
        break;

      case AppLifecycleState.paused:
        // 앱이 백그라운드로 들어갔을 때
        debugPrint('🌙 [AppLifecycleManager] 앱 백그라운드 진입');
        // 🔧 백그라운드 진입시 상태 리셋
        _isProcessingBadgeClear = false;
        break;

      case AppLifecycleState.inactive:
        // 앱이 비활성 상태 (전화, 알림 패널 등)
        debugPrint('⏸️ [AppLifecycleManager] 앱 비활성 상태');
        break;

      case AppLifecycleState.detached:
        // 앱이 완전히 종료되기 직전
        debugPrint('❌ [AppLifecycleManager] 앱 종료 직전');
        break;

      case AppLifecycleState.hidden:
        // 앱이 숨겨진 상태 (iOS에서 주로 사용)
        debugPrint('👻 [AppLifecycleManager] 앱 숨김 상태');
        break;
    }
  }

  /// 앱 시작 시 뱃지 클리어
  void _clearBadgeOnAppStart() {
    try {
      debugPrint('🚀 [AppLifecycleManager] 앱 시작 시 뱃지 클리어 시도');

      // Provider에서 NotificationProvider 가져오기
      final notificationProvider = context.read<NotificationProvider>();

      // 뱃지 클리어 실행
      notificationProvider.clearBadge();

      debugPrint('✅ [AppLifecycleManager] 앱 시작 시 뱃지 클리어 완료');
    } catch (e) {
      debugPrint('❌ [AppLifecycleManager] 앱 시작 시 뱃지 클리어 실패: $e');
      // 에러가 발생해도 앱 실행에는 영향을 주지 않음
    }
  }

  /// 🔥 앱 포그라운드 진입 시 뱃지 클리어 (중복 방지 버전)
  void _clearBadgeOnResume() {
    // 🛡️ 중복 호출 방지 체크
    final now = DateTime.now();

    // 1. 이미 처리중이면 무시
    if (_isProcessingBadgeClear) {
      debugPrint('⚠️ [AppLifecycleManager] 뱃지 클리어 이미 처리중 - 스킵');
      return;
    }

    // 2. 마지막 클리어로부터 1초 이내면 무시 (디바운싱)
    if (_lastBadgeClearTime != null &&
        now.difference(_lastBadgeClearTime!).inSeconds < 1) {
      debugPrint('⚠️ [AppLifecycleManager] 뱃지 클리어 너무 빈번 - 스킵');
      return;
    }

    // 🔥 뱃지 클리어 실행
    _isProcessingBadgeClear = true;
    _lastBadgeClearTime = now;

    // 약간의 지연 후 실행 (iOS가 상태를 정리할 시간을 줌)
    Future.delayed(Duration(milliseconds: 500), () async {
      try {
        debugPrint('🔥 [AppLifecycleManager] 포그라운드 진입 - 뱃지 클리어 시도');

        final notificationProvider = context.read<NotificationProvider>();

        // 🎯 한 번만 클리어 (iOS는 한 번으로 충분함)
        await notificationProvider.clearBadge();

        debugPrint('✅ [AppLifecycleManager] 포그라운드 진입 시 뱃지 클리어 완료');
      } catch (e) {
        debugPrint('❌ [AppLifecycleManager] 포그라운드 진입 시 뱃지 클리어 실패: $e');
      } finally {
        // 🔧 처리 완료 표시
        _isProcessingBadgeClear = false;
      }
    });
  }

  /// 강제 뱃지 클리어 (필요시 외부에서 호출 가능)
  void forceClearBadge() {
    debugPrint('💪 [AppLifecycleManager] 강제 뱃지 클리어 요청');

    try {
      final notificationProvider = context.read<NotificationProvider>();
      notificationProvider.forceClearBadge();
      debugPrint('✅ [AppLifecycleManager] 강제 뱃지 클리어 완료');
    } catch (e) {
      debugPrint('❌ [AppLifecycleManager] 강제 뱃지 클리어 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 단순히 자식 위젯을 그대로 반환
    // 실제 UI에는 영향을 주지 않고 생명주기만 관리
    return widget.child;
  }
}
