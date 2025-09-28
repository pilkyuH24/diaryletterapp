// widgets/ai/components/letter_limit_debug_widget.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/widgets/ai/services/letter_limit_service.dart';

class LetterLimitDebugWidget extends StatefulWidget {
  final VoidCallback? onLimitChanged;

  const LetterLimitDebugWidget({Key? key, this.onLimitChanged})
    : super(key: key);

  @override
  State<LetterLimitDebugWidget> createState() => _LetterLimitDebugWidgetState();
}

class _LetterLimitDebugWidgetState extends State<LetterLimitDebugWidget> {
  bool _showDebugInfo = false;
  int _usedCount = 0;
  int _totalLimit = 0;
  late LetterLimitService _limitService;

  @override
  void initState() {
    super.initState();
    _limitService = LetterLimitService();
    _loadLimitInfo();
  }

  Future<void> _loadLimitInfo() async {
    if (!kDebugMode) return;
    try {
      final used = await _limitService.getUsedCount();
      final total = await _limitService.getTotalLimit();
      if (mounted) {
        setState(() {
          _usedCount = used;
          _totalLimit = total;
        });
      }
    } catch (e) {
      debugPrint('🔧 [Debug] 리밋 정보 로드 실패: $e');
    }
  }

  Future<void> _resetLimitForTesting() async {
    if (!kDebugMode) return;
    try {
      await _limitService.resetForTesting();
      await _loadLimitInfo();
      _showDebugSnackBar('✅ 리밋이 리셋되었습니다! (사용: 0/$_totalLimit)');
      widget.onLimitChanged?.call();
    } catch (e) {
      _showDebugSnackBar('❌ 리밋 리셋 실패: $e', isError: true);
    }
  }

  Future<void> _fillLimitForTesting() async {
    if (!kDebugMode) return;
    try {
      await _limitService.fillLimitForTesting();
      await _loadLimitInfo();
      _showDebugSnackBar('🚫 리밋이 꽉 찼습니다! (사용: $_usedCount/$_totalLimit)');
      widget.onLimitChanged?.call();
    } catch (e) {
      _showDebugSnackBar('❌ 리밋 채우기 실패: $e', isError: true);
    }
  }

  Future<void> _addBonusForTesting() async {
    if (!kDebugMode) return;
    try {
      await _limitService.increaseLimitByReward();
      await _loadLimitInfo();
      _showDebugSnackBar('🎁 보너스 3회가 추가되었습니다! (총 한도: $_totalLimit)');
      widget.onLimitChanged?.call();
    } catch (e) {
      _showDebugSnackBar('❌ 보너스 추가 실패: $e', isError: true);
    }
  }

  void _showDebugSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.bug_report : Icons.engineering,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text('[DEBUG] $message')),
          ],
        ),
        backgroundColor: isError ? Colors.red[700] : Colors.blue[700],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 릴리즈 모드에서는 아무것도 표시하지 않음
    if (!kDebugMode) return const SizedBox.shrink();

    final themeProv = context.watch<ThemeProvider>();
    final fontProv = context.watch<FontProvider>();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50]?.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.engineering, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'DEBUG MODE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                  fontFamily: fontProv.fontFamily.isEmpty
                      ? null
                      : fontProv.fontFamily,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showDebugInfo = !_showDebugInfo;
                  });
                },
                icon: Icon(
                  _showDebugInfo ? Icons.expand_less : Icons.expand_more,
                  color: Colors.blue[700],
                ),
                iconSize: 20,
              ),
            ],
          ),
          if (_showDebugInfo) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.blue[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '현재 편지 생성 한도',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                          fontFamily: fontProv.fontFamily.isEmpty
                              ? null
                              : fontProv.fontFamily,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '사용: $_usedCount',
                        style: TextStyle(
                          fontSize: 14,
                          color: _usedCount >= _totalLimit
                              ? Colors.red[600]
                              : Colors.green[600],
                          fontWeight: FontWeight.bold,
                          fontFamily: fontProv.fontFamily.isEmpty
                              ? null
                              : fontProv.fontFamily,
                        ),
                      ),
                      Text(
                        ' / $_totalLimit',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: fontProv.fontFamily.isEmpty
                              ? null
                              : fontProv.fontFamily,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _usedCount >= _totalLimit
                              ? Colors.red[100]
                              : Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _usedCount >= _totalLimit ? '한도 도달' : '생성 가능',
                          style: TextStyle(
                            fontSize: 10,
                            color: _usedCount >= _totalLimit
                                ? Colors.red[700]
                                : Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontFamily: fontProv.fontFamily.isEmpty
                                ? null
                                : fontProv.fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _resetLimitForTesting,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: Text(
                            '리셋',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: fontProv.fontFamily.isEmpty
                                  ? null
                                  : fontProv.fontFamily,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            minimumSize: const Size(0, 36),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _fillLimitForTesting,
                          icon: const Icon(Icons.block, size: 16),
                          label: Text(
                            '꽉채우기',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: fontProv.fontFamily.isEmpty
                                  ? null
                                  : fontProv.fontFamily,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            minimumSize: const Size(0, 36),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addBonusForTesting,
                          icon: const Icon(Icons.add, size: 16),
                          label: Text(
                            '보너스',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: fontProv.fontFamily.isEmpty
                                  ? null
                                  : fontProv.fontFamily,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            minimumSize: const Size(0, 36),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 디버그용 플로팅 액션 버튼
class DebugFloatingActionButton extends StatelessWidget {
  final VoidCallback? onRefresh;

  const DebugFloatingActionButton({Key? key, this.onRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 릴리즈 모드에서는 아무것도 표시하지 않음
    if (!kDebugMode) return const SizedBox.shrink();

    return FloatingActionButton(
      onPressed: () {
        onRefresh?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.engineering, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('[DEBUG] 리밋 정보가 새로고침되었습니다'),
              ],
            ),
            backgroundColor: Colors.blue[700],
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      backgroundColor: Colors.blue[600],
      mini: true,
      tooltip: 'DEBUG: 리밋 정보 새로고침',
      child: const Icon(Icons.refresh, color: Colors.white),
    );
  }
}
