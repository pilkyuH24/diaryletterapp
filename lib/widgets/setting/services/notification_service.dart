// widgets/setting/services/notification_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'log_service.dart';
import 'notification_debug_service.dart' as debug;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// 플러그인 초기화
  Future<void> initialize() async {
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

      final now = tz.TZDateTime.now(tz.local);
      LogService.v('Timezone: ${tz.local.name}, now: $now');

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: _onResponse,
      );
      LogService.i('[NotificationService] 초기화 완료');
    } catch (e) {
      LogService.e('[NotificationService] 초기화 실패: $e');
    }
  }

  /// 알림 클릭 이벤트 핸들러
  void _onResponse(NotificationResponse response) {
    LogService.i(
      '[NotificationService] 알림 클릭: id=${response.id}, payload=${response.payload}',
    );
  }

  /// 권한 요청 (Android/iOS)
  Future<bool> requestPermissions() async {
    LogService.i('[NotificationService] 권한 요청');
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        LogService.v('Android permission: $status');
        return status.isGranted;
      } else if (Platform.isIOS) {
        final iosImpl = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        final granted =
            await iosImpl?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
        LogService.v('iOS permission granted: $granted');
        return granted;
      }
    } catch (e) {
      LogService.e('[NotificationService] 권한 요청 실패: $e');
    }
    return false;
  }

  /// 매일 반복 알림 설정
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    LogService.i(
      '[NotificationService] 매일 알림 설정: id=$id, time=${time.hour}:${time.minute}',
    );
    final scheduledDate = _nextInstanceOfTime(time);

    const androidDetails = AndroidNotificationDetails(
      'daily_diary',
      '일기 알림',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(sound: 'default');

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    LogService.i('[NotificationService] 매일 알림 설정 완료: $scheduledDate');
  }

  /// 주간 반복 알림 설정
  Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required List<int> weekdays, // 1=월요일, …, 7=일요일
  }) async {
    LogService.i(
      '[NotificationService] 주간 알림 설정 시작: id=$id, weekdays=$weekdays, time=${time.hour}:${time.minute}',
    );
    try {
      // 기존 알림 제거
      await cancelNotification(id);

      for (int i = 0; i < weekdays.length; i++) {
        final notifId = id + i;
        final weekday = weekdays[i];
        final scheduledDate = _nextInstanceOfWeekday(weekday, time);

        const androidDetails = AndroidNotificationDetails(
          'weekly_diary',
          '주간 일기 알림',
          importance: Importance.high,
          priority: Priority.high,
        );
        const iosDetails = DarwinNotificationDetails(sound: 'default');

        await _plugin.zonedSchedule(
          notifId,
          title,
          body,
          scheduledDate,
          const NotificationDetails(android: androidDetails, iOS: iosDetails),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );

        LogService.i(
          '[NotificationService] 요일 알림 설정 완료: id=$notifId, weekday=$weekday, at $scheduledDate',
        );
      }
    } catch (e) {
      LogService.e('[NotificationService] 주간 알림 설정 실패: $e');
    }
  }

  /// 단일 알림 취소
  Future<void> cancelNotification(int id) async {
    LogService.i('[NotificationService] 알림 취소: id=$id');
    try {
      await _plugin.cancel(id);
      LogService.i('[NotificationService] 알림 취소 완료: id=$id');
    } catch (e) {
      LogService.e('[NotificationService] 알림 취소 실패: $e');
    }
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    LogService.i('[NotificationService] 모든 알림 취소');
    try {
      await _plugin.cancelAll();
      LogService.i('[NotificationService] 모든 알림 취소 완료');
    } catch (e) {
      LogService.e('[NotificationService] 모든 알림 취소 실패: $e');
    }
  }

  /// iOS 전용: 뱃지 클리어
  Future<void> clearBadge() async {
    LogService.i('[NotificationService] 뱃지 클리어');
    if (Platform.isIOS) {
      final iosImpl = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosImpl != null) {
        try {
          await _plugin.show(
            -1,
            '',
            '',
            const NotificationDetails(
              iOS: DarwinNotificationDetails(
                badgeNumber: 0,
                presentAlert: false,
                presentSound: false,
                presentBadge: true,
              ),
            ),
          );
          await Future.delayed(const Duration(milliseconds: 50));
          await _plugin.cancel(-1);
          LogService.i('[NotificationService] iOS 뱃지 클리어 완료');
        } catch (e) {
          LogService.e('[NotificationService] 뱃지 클리어 실패: $e');
        }
      }
    }
  }

  /// 앱 재개 시 자동 뱃지 클리어
  Future<void> clearBadgeOnAppResume() async {
    LogService.i('[NotificationService] 앱 재개 시 뱃지 자동 클리어');
    await clearBadge();
  }

  // ──────── Helpers ─────────────────────────────────

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextInstanceOfWeekday(int weekday, TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    int daysUntil = (weekday - now.weekday) % 7;
    if (daysUntil == 0 &&
        (now.hour > time.hour ||
            (now.hour == time.hour && now.minute >= time.minute))) {
      daysUntil = 7;
    }
    return tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + daysUntil,
      time.hour,
      time.minute,
    );
  }

  // ──────── Debug-only ────────────────────────────

  /// 즉시 테스트 알림
  void showTestNotification([String? msg]) {
    if (kDebugMode) {
      debug.NotificationDebugService.showTestNotification(
        _plugin,
        customMessage: msg,
      );
    }
  }

  /// 1분 후 지연 테스트 알림
  void showDelayedTest() {
    if (kDebugMode) {
      debug.NotificationDebugService.showDelayedTestNotification(_plugin);
    }
  }

  /// 대기 중인 알림 목록 출력
  Future<void> debugPending() async {
    if (kDebugMode) {
      await debug.NotificationDebugService.debugPendingNotifications(_plugin);
    }
  }
}
