// lib/widgets/diary/components/today_banner.dart
import 'package:flutter/material.dart';

class TodayBanner extends StatelessWidget {
  final DateTime selectedDate;
  final int count;
  final VoidCallback? onTodayPressed;

  const TodayBanner({
    Key? key,
    required this.selectedDate,
    required this.count,
    this.onTodayPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      color: scheme.primary,
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일 - $count개',
              style: const TextStyle(
                // fontFamily: 'OngeulipKonKonche',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.today, color: Colors.white),
            onPressed: onTodayPressed,
          ),
        ],
      ),
    );
  }
}
