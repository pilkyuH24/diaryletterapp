import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/const/theme_colors.dart';
import 'package:diaryletter/model/letter_model.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/widgets/ai/services/letter_service.dart';
import 'package:diaryletter/widgets/ai/screens/letter_history/components/letter_card.dart';
import 'package:diaryletter/widgets/ai/screens/letter_history/components/letter_view.dart';

class LetterHistoryScreen extends StatefulWidget {
  @override
  _LetterHistoryScreenState createState() => _LetterHistoryScreenState();
}

class _LetterHistoryScreenState extends State<LetterHistoryScreen> {
  List<LetterModel> _letters = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLetters();
  }

  Future<void> _loadLetters() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final letters = await LetterService.getLetters();

      setState(() {
        _letters = letters;
        _isLoading = false;
      });

      debugPrint('✅ [Letter History] 편지 목록 로드 완료 - ${letters.length}개');
    } catch (e) {
      debugPrint('❌ [Letter History] 편지 목록 로드 실패: $e');

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteLetter(LetterModel letter) async {
    final fontProv = context.read<FontProvider>();
    final themeProv = context.read<ThemeProvider>();
    final tc = themeProv.colors;

    // 삭제 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tc.background,
        title: Text('편지 삭제'),
        content: Text(
          '이 편지를 삭제하시겠어요?\n삭제한 편지는 복구할 수 없습니다.',
          style: TextStyle(
            fontSize: fontProv.fontSize - 2,
            color: tc.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '취소',
              style: TextStyle(
                fontSize: fontProv.fontSize - 2,
                color: tc.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '삭제',
              style: TextStyle(
                fontSize: fontProv.fontSize - 2,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      debugPrint('🗑️ [Letter History] 편지 삭제 시작: ${letter.title}');

      // 서버에서 삭제
      await LetterService.deleteLetter(letter.id);

      // 로컬 리스트에서 제거
      setState(() {
        _letters.removeWhere((l) => l.id == letter.id);
      });

      debugPrint('✅ [Letter History] 편지 삭제 완료');

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('편지가 삭제되었습니다', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('❌ [Letter History] 편지 삭제 실패: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '편지 삭제에 실패했습니다: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _viewLetter(LetterModel letter) async {
    debugPrint('👀 [Letter History] 편지 보기: ${letter.title}');

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LetterView(
          letterTitle: letter.title,
          letterContent: letter.content,
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final fontProv = context.watch<FontProvider>();
    final tc = themeProv.colors;

    return Scaffold(
      backgroundColor: tc.surface,
      appBar: AppBar(
        title: Text(
          '편지 보관함',
          style: TextStyle(
            color: tc.textPrimary,
            fontFamily: fontProv.fontFamily.isEmpty
                ? null
                : fontProv.fontFamily,
          ),
        ),
        backgroundColor: tc.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tc.textPrimary),
          onPressed: () => Navigator.pop(context, true), // true 반환 (개수 업데이트용)
        ),
        actions: [
          // 새로고침 버튼
          IconButton(
            icon: Icon(Icons.refresh, color: tc.textPrimary),
            onPressed: _loadLetters,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              tc.surface,
              tc.surface,
              tc.accent.withOpacity(0.8),
              tc.accent,
            ],
          ),
        ),
        child: _buildBody(tc, fontProv),
      ),
    );
  }

  Widget _buildBody(ThemeColors tc, FontProvider fontProv) {
    if (_isLoading) {
      return _buildLoadingState(tc, fontProv);
    }

    if (_error != null) {
      return _buildErrorState(tc, fontProv);
    }

    if (_letters.isEmpty) {
      return _buildEmptyState(tc, fontProv);
    }

    return _buildLetterList(tc, fontProv);
  }

  // 로딩 상태
  Widget _buildLoadingState(ThemeColors tc, FontProvider fontProv) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: tc.primary),
          SizedBox(height: 16),
          Text(
            '편지를 불러오는 중...',
            style: TextStyle(
              color: tc.textSecondary,
              fontSize: 16,
              fontFamily: fontProv.fontFamily.isEmpty
                  ? null
                  : fontProv.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  // 오류 상태
  Widget _buildErrorState(ThemeColors tc, FontProvider fontProv) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            SizedBox(height: 16),
            Text(
              '편지를 불러오지 못했어요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: tc.textPrimary,
                fontFamily: fontProv.fontFamily.isEmpty
                    ? null
                    : fontProv.fontFamily,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: tc.textSecondary,
                fontFamily: fontProv.fontFamily.isEmpty
                    ? null
                    : fontProv.fontFamily,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadLetters,
              icon: Icon(Icons.refresh),
              label: Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: tc.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 빈 상태
  Widget _buildEmptyState(ThemeColors tc, FontProvider fontProv) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: tc.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.mail_outline, size: 64, color: tc.primary),
            ),
            SizedBox(height: 24),
            Text(
              '아직 받은 편지가 없어요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: tc.textPrimary,
                fontFamily: fontProv.fontFamily.isEmpty
                    ? null
                    : fontProv.fontFamily,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '일기를 작성하고 AI에게 편지를 받아보세요!\n따뜻하고 개인화된 메시지를 만나보실 수 있어요.',
              style: TextStyle(
                fontSize: 14,
                color: tc.textSecondary,
                height: 1.5,
                fontFamily: fontProv.fontFamily.isEmpty
                    ? null
                    : fontProv.fontFamily,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, false), // 편지 생성 화면으로
              icon: Icon(Icons.edit),
              label: Text('첫 편지 받기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: tc.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 편지 목록
  Widget _buildLetterList(ThemeColors tc, FontProvider fontProv) {
    return Column(
      children: [
        // 상단 정보
        Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: tc.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tc.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.library_books, color: tc.textPrimary, size: 20),
              SizedBox(width: 8),
              Text(
                '총 ${_letters.length}개의 편지가 저장되어 있어요',
                style: TextStyle(
                  color: tc.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: fontProv.fontFamily.isEmpty
                      ? null
                      : fontProv.fontFamily,
                ),
              ),
            ],
          ),
        ),

        // 편지 목록
        Expanded(
          child: ListView.builder(
            itemCount: _letters.length,
            itemBuilder: (context, index) {
              final letter = _letters[index];
              return LetterCard(
                letter: letter,
                onTap: () => _viewLetter(letter),
                onDelete: () => _deleteLetter(letter),
              );
            },
          ),
        ),
      ],
    );
  }
}
