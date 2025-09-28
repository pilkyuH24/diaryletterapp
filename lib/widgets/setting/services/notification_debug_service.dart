// widgets/setting/services/notification_debug_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// 디버그 전용: 즉시, 지연, 대기 알림 확인, 배지 클리어 등
class NotificationDebugService {
  static Future<void> showTestNotification(
    FlutterLocalNotificationsPlugin plugin, {
    String? customMessage,
  }) async {
    final message = customMessage ?? '오늘 뭔 일 있었어? 일기로 남겨봐! ✨';
    const details = NotificationDetails(
      android: AndroidNotificationDetails('test_diary', '테스트 알림'),
      iOS: DarwinNotificationDetails(badgeNumber: 1),
    );
    await plugin.show(0, '일기장 📖', message, details);
  }

  static Future<void> showDelayedTestNotification(
    FlutterLocalNotificationsPlugin plugin,
  ) {
    final now = tz.TZDateTime.now(tz.local);
    final schedule = now.add(const Duration(minutes: 1));
    const details = NotificationDetails(
      android: AndroidNotificationDetails('test_delayed', '지연 테스트 알림'),
      iOS: DarwinNotificationDetails(badgeNumber: 1),
    );
    return plugin.zonedSchedule(
      888,
      '🎯 백그라운드 테스트',
      '1분 후 알림',
      schedule,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> debugPendingNotifications(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final list = await plugin.pendingNotificationRequests();
    debugPrint('📋 Pending notifications (${list.length}):');
    for (var n in list) {
      debugPrint(' - [${n.id}] ${n.title} / ${n.body}');
    }
  }
}
