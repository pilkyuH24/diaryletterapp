import 'dart:io';

import 'package:diaryletter/providers/font_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:diaryletter/const/colors.dart';
import 'package:diaryletter/providers/theme_provider.dart';

typedef OnDaySelected = void Function(DateTime, DateTime);

class MainCalendar extends StatelessWidget {
  final OnDaySelected onDaySelected;
  final DateTime selectedDate;
  final DateTime focusedDay;
  final Set<DateTime> datesWithDiary;
  final Function(DateTime)? onPageChanged;

  const MainCalendar({
    Key? key,
    required this.onDaySelected,
    required this.selectedDate,
    required this.focusedDay,
    this.datesWithDiary = const {},
    this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final themeProv = context.watch<ThemeProvider>();
    final fontProv = context.watch<FontProvider>();

    return TableCalendar(
      locale: 'ko_kr',
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      rowHeight: Platform.isAndroid ? 44 : 52,
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle(
          color: themeProv.colors.textPrimary,
          height: 1.2,
        ),
        weekdayStyle: TextStyle(
          color: themeProv.colors.textPrimary,
          height: 1.2,
        ),
      ),
      selectedDayPredicate: (d) =>
          d.year == selectedDate.year &&
          d.month == selectedDate.month &&
          d.day == selectedDate.day,
      focusedDay: focusedDay,
      firstDay: DateTime(1800),
      lastDay: DateTime(3000),
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: themeProv.colors.textPrimary,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: themeProv.colors.textPrimary,
        ),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: fontProv.fontSize + 2,
          color: scheme.onBackground,
        ),
      ),
      calendarStyle: CalendarStyle(
        isTodayHighlighted: false,
        defaultDecoration: BoxDecoration(),
        weekendDecoration: BoxDecoration(),
        selectedDecoration: BoxDecoration(),
        defaultTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        weekendTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        selectedTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: scheme.primary,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (ctx, day, _) =>
            _buildDayWithIndicator(ctx, day, false, themeProv: themeProv),
        selectedBuilder: (ctx, day, _) =>
            _buildDayWithIndicator(ctx, day, true, themeProv: themeProv),
        todayBuilder: (ctx, day, _) => _buildDayWithIndicator(
          ctx,
          day,
          false,
          isToday: true,
          themeProv: themeProv,
        ),
      ),
    );
  }

  Widget _buildDayWithIndicator(
    BuildContext context,
    DateTime day,
    bool isSelected, {
    bool isToday = false,
    required ThemeProvider themeProv,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final hasDiary = datesWithDiary.any(
      (d) => d.year == day.year && d.month == day.month && d.day == day.day,
    );

    // 텍스트/배경 색 결정
    final textColor = isSelected ? Colors.white : scheme.onSurface;
    final bgColor = isSelected ? scheme.primary : null;
    final dotColor = hasDiary ? SUCCESS_COLOR : Colors.transparent;

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 날짜 텍스트만 원형 배경으로 감싸기
          Container(
            width: 32,
            height: 32,
            decoration: isSelected
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: themeProv.isDarkMode
                        ? Colors.grey.shade800
                        : bgColor,
                  )
                : null,
            child: Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontFamily: 'OngeulipKonKonche',
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          // 일기 표시 점은 별도로 배치
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
        ],
      ),
    );
  }
}
