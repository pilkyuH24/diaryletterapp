// lib/providers/notification_provider.dart

// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diaryletter/widgets/setting/services/notification_service.dart';
import 'package:diaryletter/widgets/setting/services/log_service.dart';

enum NotificationMode { disabled, daily, weekly }

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  // 설정 상태
  NotificationMode _mode = NotificationMode.disabled;
  TimeOfDay _time = const TimeOfDay(hour: 20, minute: 0);
  List<bool> _selectedWeekdays = List<bool>.filled(7, false);
  bool _isEnabled = false;
  String _customMessage = '오늘 뭔 일 있었어? 일기로 남겨봐! ✨';
  bool _isBadgeCleared = true;

  // Getters
  NotificationMode get mode => _mode;
  TimeOfDay get time => _time;
  List<bool> get selectedWeekdays => _selectedWeekdays;
  bool get isEnabled => _isEnabled;
  String get customMessage => _customMessage;
  bool get isBadgeCleared => _isBadgeCleared;

  final List<String> weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];

  /// 초기화
  Future<void> initialize() async {
    // LogService.i('[NotificationProvider] 초기화 시작');
    await _loadSettings();
    await _notificationService.initialize();
    await clearBadge();
    notifyListeners();
    LogService.i('[NotificationProvider] 초기화 완료');
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('notification_enabled') ?? false;
    _mode = NotificationMode.values[prefs.getInt('notification_mode') ?? 0];
    _time = TimeOfDay(
      hour: prefs.getInt('notification_hour') ?? 20,
      minute: prefs.getInt('notification_minute') ?? 0,
    );
    _customMessage =
        prefs.getString('notification_message') ?? '오늘 뭔 일 있었어? 일기로 남겨봐! ✨';
    for (int i = 0; i < 7; i++) {
      _selectedWeekdays[i] = prefs.getBool('weekday_$i') ?? false;
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_enabled', _isEnabled);
    await prefs.setInt('notification_mode', _mode.index);
    await prefs.setInt('notification_hour', _time.hour);
    await prefs.setInt('notification_minute', _time.minute);
    await prefs.setString('notification_message', _customMessage);
    for (int i = 0; i < 7; i++) {
      await prefs.setBool('weekday_$i', _selectedWeekdays[i]);
    }
  }

  Future<void> toggleNotification(bool enabled) async {
    if (enabled) {
      final granted = await _notificationService.requestPermissions();
      if (!granted) {
        LogService.w('[NotificationProvider] 알림 권한 거부됨');
        return;
      }
    }

    _isEnabled = enabled;
    if (_isEnabled) {
      await _scheduleNotifications();
    } else {
      await _notificationService.cancelAllNotifications();
      await clearBadge();
    }

    await _saveSettings();
    notifyListeners();
    LogService.i('[NotificationProvider] 알림 ${enabled ? "활성화" : "비활성화"} 완료');
  }

  Future<void> setNotificationMode(NotificationMode mode) async {
    _mode = mode;
    if (_isEnabled) await _scheduleNotifications();
    await _saveSettings();
    notifyListeners();
    LogService.i('[NotificationProvider] 모드 변경: $_mode');
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    _time = time;
    if (_isEnabled) await _scheduleNotifications();
    await _saveSettings();
    notifyListeners();
    LogService.i('[NotificationProvider] 시간 변경: ${formattedTime}');
  }

  Future<void> toggleWeekday(int index) async {
    _selectedWeekdays[index] = !_selectedWeekdays[index];
    if (_isEnabled && _mode == NotificationMode.weekly) {
      await _scheduleNotifications();
    }
    await _saveSettings();
    notifyListeners();
    LogService.i(
      '[NotificationProvider] 요일 토글: ${weekdayNames[index]} = ${_selectedWeekdays[index]}',
    );
  }

  Future<void> setCustomMessage(String message) async {
    _customMessage = message;
    if (_isEnabled) await _scheduleNotifications();
    await _saveSettings();
    notifyListeners();
    LogService.i('[NotificationProvider] 메시지 변경: $_customMessage');
  }

  Future<void> _scheduleNotifications() async {
    await _notificationService.cancelAllNotifications();

    if (!_isEnabled) return;

    switch (_mode) {
      case NotificationMode.daily:
        await _notificationService.scheduleDaily(
          id: 1,
          title: '일기장 📖',
          body: _customMessage,
          time: _time,
        );
        break;
      case NotificationMode.weekly:
        final days = <int>[];
        for (int i = 0; i < _selectedWeekdays.length; i++) {
          if (_selectedWeekdays[i]) days.add(i + 1);
        }
        if (days.isNotEmpty) {
          await _notificationService.scheduleWeekly(
            id: 100,
            title: '일기장 📖',
            body: _customMessage,
            time: _time,
            weekdays: days,
          );
        }
        break;
      case NotificationMode.disabled:
        break;
    }

    LogService.i(
      '[NotificationProvider] 스케줄링 완료: 모드=$_mode, 시간=${formattedTime}, 요일=${selectedWeekdaysText}',
    );
  }

  Future<void> sendTestNotification() async {
    LogService.i('[NotificationProvider] 테스트 알림 요청');
    _notificationService.showTestNotification(_customMessage);
    _isBadgeCleared = false;
    notifyListeners();
  }

  Future<void> sendDelayedTestNotification() async {
    LogService.i('[NotificationProvider] 지연 테스트 알림 요청');
    _notificationService.showDelayedTest();
    _isBadgeCleared = false;
    notifyListeners();
  }

  Future<void> clearBadge() async {
    try {
      await _notificationService.clearBadge();
      _isBadgeCleared = true;
      notifyListeners();
      LogService.i('[NotificationProvider] 뱃지 클리어 완료');
    } catch (e) {
      LogService.e('[NotificationProvider] 뱃지 클리어 실패: $e');
    }
  }

  Future<void> onAppResume() async {
    LogService.i('[NotificationProvider] 앱 재개 감지');
    await clearBadge();
  }

  Future<void> forceClearBadge() async {
    LogService.i('[NotificationProvider] 강제 뱃지 클리어 시작');
    await clearBadge();
    await Future.delayed(const Duration(milliseconds: 200));
    await clearBadge();
    LogService.i('[NotificationProvider] 강제 뱃지 클리어 완료');
  }

  int get selectedWeekdaysCount => _selectedWeekdays.where((v) => v).length;

  String get selectedWeekdaysText {
    if (selectedWeekdaysCount == 0) return '없음';
    if (selectedWeekdaysCount == 7) return '매일';
    return [
      for (int i = 0; i < 7; i++)
        if (_selectedWeekdays[i]) weekdayNames[i],
    ].join(', ');
  }

  String get formattedTime {
    final h = _time.hour.toString().padLeft(2, '0');
    final m = _time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void printDebugInfo() {
    LogService.i(
      '[NotificationProvider] 디버그 정보: '
      'enabled=$_isEnabled, mode=$_mode, time=${formattedTime}, '
      'badgeCleared=$_isBadgeCleared, weekdays=${selectedWeekdaysText}',
    );
  }
}
