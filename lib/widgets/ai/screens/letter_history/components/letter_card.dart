import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/model/letter_model.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';

class LetterCard extends StatelessWidget {
  final LetterModel letter;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const LetterCard({Key? key, required this.letter, this.onTap, this.onDelete})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final fontProv = context.watch<FontProvider>();
    final tc = themeProv.colors;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              // ▶ 카드 배경
              color: tc.background,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: Offset(0, 3),
                ),
              ],
              border: Border.all(color: tc.primary.withOpacity(0.1), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단: 제목과 액션
                Row(
                  children: [
                    // 편지 아이콘 (변경 없음)
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: tc.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.mail, color: tc.textPrimary, size: 20),
                    ),

                    SizedBox(width: 12),

                    // 제목 텍스트 (이미 tc.textPrimary)
                    Expanded(
                      child: Text(
                        letter.title,
                        style: TextStyle(
                          fontSize: fontProv.fontSize,
                          fontWeight: FontWeight.bold,
                          color: tc.textPrimary,
                          fontFamily: fontProv.fontFamily.isEmpty
                              ? null
                              : fontProv.fontFamily,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // 삭제 버튼 (변경 없음)
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete_outline,
                          color: tc.textSecondary,
                          size: 20,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.all(4),
                      ),
                  ],
                ),

                SizedBox(height: 12),

                // 편지 내용 미리보기
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tc.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: tc.background),
                  ),
                  child: Text(
                    _getPreviewText(letter.content),
                    style: TextStyle(
                      fontSize: fontProv.fontSize - 2,
                      // ▶ 미리보기 텍스트도 tc.textPrimary 로 변경
                      color: tc.textPrimary,
                      height: 1.4,
                      fontFamily: fontProv.fontFamily.isEmpty
                          ? null
                          : fontProv.fontFamily,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                SizedBox(height: 12),

                // 하단: 정보들
                Row(
                  children: [
                    // 생성 날짜
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.blue[700],
                          ),
                          SizedBox(width: 4),
                          Text(
                            _formatDate(letter.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                              fontFamily: fontProv.fontFamily.isEmpty
                                  ? null
                                  : fontProv.fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 8),

                    // 일기 개수
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[100]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.book, size: 12, color: Colors.green[700]),
                          SizedBox(width: 4),
                          Text(
                            '${letter.diaryCount}개 일기',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                              fontFamily: fontProv.fontFamily.isEmpty
                                  ? null
                                  : fontProv.fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 8),

                    // 분석 기간
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple[100]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.date_range,
                            size: 12,
                            color: Colors.purple[700],
                          ),
                          SizedBox(width: 4),
                          Text(
                            _formatPeriod(letter.periodStart, letter.periodEnd),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.purple[700],
                              fontWeight: FontWeight.w500,
                              fontFamily: fontProv.fontFamily.isEmpty
                                  ? null
                                  : fontProv.fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Spacer(),

                    // 읽기 화살표
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: tc.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 편지 내용 미리보기 텍스트 생성
  String _getPreviewText(String content) {
    // 줄바꿈 제거하고 공백 정리
    final cleanContent = content
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // 120자 제한
    if (cleanContent.length <= 120) {
      return cleanContent;
    }

    return '${cleanContent.substring(0, 120)}...';
  }

  // 날짜 포맷팅 (7월 25일)
  String _formatDate(DateTime date) {
    return '${date.month}월 ${date.day}일';
  }

  // 분석 기간 포맷팅
  String _formatPeriod(DateTime start, DateTime end) {
    if (start.month == end.month) {
      // 같은 달: "7/20-25"
      return '${start.month}/${start.day}-${end.day}';
    } else {
      // 다른 달: "7/30-8/5"
      return '${start.month}/${start.day}-${end.month}/${end.day}';
    }
  }
}
