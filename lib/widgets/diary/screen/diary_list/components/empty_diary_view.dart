import 'package:flutter/material.dart'; //diary_list에서 사용

class EmptyDiaryView extends StatelessWidget {
  final VoidCallback onWriteDiary;
  final Color accentColor;
  final Color textColor;

  const EmptyDiaryView({
    Key? key,
    required this.onWriteDiary,
    required this.accentColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 80, color: textColor),
          const SizedBox(height: 16),
          Text(
            '아직 작성한 일기가 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 일기를 작성해보세요!',
            style: TextStyle(fontSize: 14, color: textColor),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onWriteDiary,
            icon: Icon(Icons.edit),
            label: Text('일기 쓰기', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
