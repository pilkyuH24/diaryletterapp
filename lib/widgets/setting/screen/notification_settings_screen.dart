// widgets/setting/screen/notification_settings_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/providers/notification_provider.dart';

import 'package:flutter/foundation.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final notificationProv = context.watch<NotificationProvider>();
    final tc = themeProv.colors;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: tc.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          '알림 설정',
          style: TextStyle(
            color: tc.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: tc.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: tc.surface,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // 알림 활성화/비활성화
            _buildSection('알림 설정', [
              _buildSwitchTile(
                title: '알림 활성화',
                subtitle: '일기 작성 알림을 받습니다',
                value: notificationProv.isEnabled,
                onChanged: (value) =>
                    notificationProv.toggleNotification(value),
                themeProv: themeProv,
              ),
            ], themeProv),

            // 알림이 활성화된 경우에만 나머지 옵션 표시
            if (notificationProv.isEnabled) ...[
              // 알림 모드 선택
              _buildSection('알림 주기', [
                _buildRadioTile<NotificationMode>(
                  title: '매일',
                  subtitle: '매일 같은 시간에 알림',
                  value: NotificationMode.daily,
                  groupValue: notificationProv.mode,
                  onChanged: (value) =>
                      notificationProv.setNotificationMode(value!),
                  themeProv: themeProv,
                ),
                _buildRadioTile<NotificationMode>(
                  title: '특정 요일',
                  subtitle: '선택한 요일에만 알림',
                  value: NotificationMode.weekly,
                  groupValue: notificationProv.mode,
                  onChanged: (value) =>
                      notificationProv.setNotificationMode(value!),
                  themeProv: themeProv,
                ),
              ], themeProv),

              // 알림 시간 설정
              _buildSection('알림 시간', [
                _buildTimeTile(
                  title: '알림 시간',
                  subtitle: '${notificationProv.formattedTime}',
                  onTap: () =>
                      _showTimePicker(context, notificationProv, themeProv),
                  themeProv: themeProv,
                ),
              ], themeProv),

              // 주간 모드일 때 요일 선택
              if (notificationProv.mode == NotificationMode.weekly)
                _buildSection('알림 요일', [
                  _buildWeekdaySelector(notificationProv, themeProv),
                ], themeProv),

              // 커스텀 메시지
              _buildSection('알림 메시지', [
                _buildMessageTile(
                  title: '알림 메시지',
                  subtitle: notificationProv.customMessage,
                  onTap: () =>
                      _showMessageDialog(context, notificationProv, themeProv),
                  themeProv: themeProv,
                ),
              ], themeProv),

              // ◆ 테스트 알림 섹션: 디버그 모드에서만 노출
              if (notificationProv.isEnabled && kDebugMode)
                // 테스트 알림
                _buildSection('테스트', [
                  _buildActionTile(
                    title: '즉시 테스트 알림',
                    subtitle: '지금 바로 알림을 확인해보세요',
                    icon: Icons.notifications_active,
                    onTap: () =>
                        _sendTestNotification(context, notificationProv),
                    themeProv: themeProv,
                  ),
                  // 🆕 iOS 백그라운드 테스트용
                  if (Platform.isIOS)
                    _buildActionTile(
                      title: '1분 후 테스트 알림',
                      subtitle: '백그라운드 알림 테스트 (iOS 전용)',
                      icon: Icons.schedule,
                      onTap: () => _sendDelayedTestNotification(
                        context,
                        notificationProv,
                      ),
                      themeProv: themeProv,
                    ),
                  // 🔴 뱃지 클리어 테스트 버튼 추가
                  _buildActionTile(
                    title: '뱃지 클리어 테스트',
                    subtitle: '뱃지를 강제로 제거합니다',
                    icon: Icons.clear_all,
                    onTap: () => _testBadgeClear(context, notificationProv),
                    themeProv: themeProv,
                  ),
                ], themeProv),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
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
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'OngeulipKonKonche',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: themeProv.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required ThemeProvider themeProv,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: themeProv.colors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'OngeulipKonKonche',
            fontWeight: FontWeight.w600,
            color: themeProv.colors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'OngeulipKonKonche',
            color: themeProv.colors.textSecondary,
            fontSize: 12,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: themeProv.colors.primary,
      ),
    );
  }

  Widget _buildRadioTile<T>({
    required String title,
    required String subtitle,
    required T value,
    required T groupValue,
    required Function(T?) onChanged,
    required ThemeProvider themeProv,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: themeProv.colors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: RadioListTile<T>(
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'OngeulipKonKonche',
            fontWeight: FontWeight.w600,
            color: themeProv.colors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'OngeulipKonKonche',
            color: themeProv.colors.textSecondary,
            fontSize: 12,
          ),
        ),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: themeProv.colors.primary,
      ),
    );
  }

  Widget _buildTimeTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeProvider themeProv,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: themeProv.colors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(Icons.access_time, color: themeProv.colors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'OngeulipKonKonche',
            fontWeight: FontWeight.w600,
            color: themeProv.colors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'OngeulipKonKonche',
            color: themeProv.colors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: themeProv.colors.textPrimary,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildMessageTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeProvider themeProv,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: themeProv.colors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(Icons.message, color: themeProv.colors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'OngeulipKonKonche',
            fontWeight: FontWeight.w600,
            color: themeProv.colors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'OngeulipKonKonche',
            color: themeProv.colors.textSecondary,
            fontSize: 12,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: themeProv.colors.textPrimary,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required ThemeProvider themeProv,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: themeProv.colors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: themeProv.colors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'OngeulipKonKonche',
            fontWeight: FontWeight.w600,
            color: themeProv.colors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'OngeulipKonKonche',
            color: themeProv.colors.textSecondary,
            fontSize: 12,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildWeekdaySelector(
    NotificationProvider notificationProv,
    ThemeProvider themeProv,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: themeProv.colors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '요일 선택',
              style: TextStyle(
                fontFamily: 'OngeulipKonKonche',
                fontWeight: FontWeight.w600,
                color: themeProv.colors.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final isSelected = notificationProv.selectedWeekdays[index];
                return GestureDetector(
                  onTap: () => notificationProv.toggleWeekday(index),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? themeProv.colors.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? themeProv.colors.primary
                            : themeProv.colors.textSecondary,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        notificationProv.weekdayNames[index],
                        style: TextStyle(
                          fontFamily: 'OngeulipKonKonche',
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : themeProv.colors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              '선택된 요일: ${notificationProv.selectedWeekdaysText}',
              style: TextStyle(
                fontFamily: 'OngeulipKonKonche',
                color: themeProv.colors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimePicker(
    BuildContext context,
    NotificationProvider notificationProv,
    ThemeProvider themeProv,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: notificationProv.time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              dialBackgroundColor: themeProv.colors.primary,
              hourMinuteTextColor: themeProv.colors.background,
              entryModeIconColor: themeProv.colors.textSecondary,
              dialHandColor: themeProv.isDarkMode
                  ? themeProv.colors.textSecondary
                  : themeProv.colors.background,
              dialTextColor: MaterialStateColor.resolveWith((states) {
                return states.contains(MaterialState.selected)
                    ? themeProv.colors.primary
                    // : themeProv.colors.textPrimary;
                    : themeProv.colors.background;
              }),
              dialTextStyle: WidgetStateTextStyle.resolveWith((states) {
                return TextStyle(
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w700
                      : FontWeight.normal,
                );
              }),
              backgroundColor: themeProv.colors.background,
              helpTextStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ), // 상단 "Select time" 텍스트
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: themeProv.colors.textSecondary,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'OngeulipKonKonche',
                ),
              ), // Cancel 버튼
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: themeProv.colors.textSecondary,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'OngeulipKonKonche',
                ),
              ), // OK 버튼
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await notificationProv.setNotificationTime(picked);
    }
  }

  Future<void> _showMessageDialog(
    BuildContext context,
    NotificationProvider notificationProv,
    ThemeProvider themeProv,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: notificationProv.customMessage,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: themeProv.colors.background,
        title: Text(
          '알림 메시지 설정',
          style: TextStyle(
            fontFamily: 'OngeulipKonKonche',
            fontSize: 18,
            color: themeProv.colors.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          maxLength: 100,
          style: TextStyle(
            fontFamily: 'OngeulipKonKonche',
            color: themeProv.colors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: '알림 메시지를 입력하세요',
            hintStyle: TextStyle(
              fontFamily: 'OngeulipKonKonche',
              color: themeProv.colors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: themeProv.colors.textSecondary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: themeProv.colors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              '취소',
              style: TextStyle(
                fontFamily: 'OngeulipKonKonche',
                color: themeProv.colors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(
              '확인',
              style: TextStyle(
                fontFamily: 'OngeulipKonKonche',
                color: themeProv.colors.primary,
              ),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await notificationProv.setCustomMessage(result);
    }
  }

  Future<void> _sendTestNotification(
    BuildContext context,
    NotificationProvider notificationProv,
  ) async {
    await notificationProv.sendTestNotification();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '테스트 알림을 보냈습니다!',
            style: TextStyle(fontFamily: 'OngeulipKonKonche'),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 🆕 1분 후 테스트 알림 (iOS 백그라운드 테스트용)
  Future<void> _sendDelayedTestNotification(
    BuildContext context,
    NotificationProvider notificationProv,
  ) async {
    await notificationProv.sendDelayedTestNotification();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '1분 후 알림이 설정됨! 앱을 백그라운드로 보내세요 📱',
            style: TextStyle(fontFamily: 'OngeulipKonKonche'),
          ),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// 🔴 뱃지 클리어 테스트 메서드 추가
  Future<void> _testBadgeClear(
    BuildContext context,
    NotificationProvider notificationProv,
  ) async {
    try {
      debugPrint('🧪 [Test] 뱃지 클리어 테스트 시작');

      await notificationProv.clearBadge();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '뱃지 클리어 완료! 📱',
              style: TextStyle(fontFamily: 'OngeulipKonKonche'),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }

      debugPrint('✅ [Test] 뱃지 클리어 테스트 완료');
    } catch (e) {
      debugPrint('❌ [Test] 뱃지 클리어 테스트 실패: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '뱃지 클리어 실패: $e',
              style: TextStyle(fontFamily: 'OngeulipKonKonche'),
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
