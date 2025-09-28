// lib/widgets/diary/screen/diary_read/diary_read_screen.dart

import 'dart:ui';
import 'package:diaryletter/const/diary_option.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/const/theme_colors.dart';
import 'package:diaryletter/const/colors.dart';
import 'package:diaryletter/model/diary_model.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/widgets/ui/font_settings_dialog.dart';
import 'package:diaryletter/widgets/diary/screen/diary_write/diary_write_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiaryReadScreen extends StatefulWidget {
  final DiaryModel diary;
  const DiaryReadScreen({required this.diary, Key? key}) : super(key: key);

  @override
  State<DiaryReadScreen> createState() => _DiaryReadScreenState();
}

class _DiaryReadScreenState extends State<DiaryReadScreen> {
  static const double _baseIconSize = 26.0;
  static const double _horizontalPadding = 16.0;
  static const double _verticalPadding = 16.0;

  late DiaryModel _diary;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    // 로컬 상태로 복사
    _diary = widget.diary;

    // 🔄 이 화면에서는 가로모드도 허용
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    // ]);
  }

  @override
  void dispose() {
    // 🔄 화면 나갈 때 다시 세로모드만 허용
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    // ]);
    super.dispose();
  }

  Future<bool> _handleWillPop() async {
    _popWithOrientationInfo(refresh: false);
    return false;
  }

  void _popWithOrientationInfo({required bool refresh}) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    Navigator.pop(context, {'refresh': refresh, 'wasLandscape': isLandscape});
  }

  /// DB에서 최신 일기 데이터만 불러오기
  Future<DiaryModel?> _fetchDiaryById(String id) async {
    final data = await Supabase.instance.client
        .from('diary')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return DiaryModel.fromJson(json: data);
  }

  Future<void> _editDiary() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DiaryWriteScreen(selectedDate: _diary.date, editingDiary: _diary),
      ),
    );
    if (result != null && result['refresh'] == true) {
      final updated = await _fetchDiaryById(_diary.id);
      if (updated != null) {
        setState(() => _diary = updated);
      }
    }
  }

  Future<void> _deleteDiary() async {
    final themeProv = context.read<ThemeProvider>();
    final ThemeColors tc = themeProv.colors;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: tc.background,
        title: const Text('일기 삭제'),
        content: const Text('이 일기를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소', style: TextStyle(color: tc.textPrimary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isDeleting = true);
    try {
      await Supabase.instance.client.from('diary').delete().match({
        'id': _diary.id,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '일기가 삭제되었습니다',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      _popWithOrientationInfo(refresh: true);
    } catch (e) {
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontProv = context.watch<FontProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final ThemeColors tc = themeProv.colors;
    final Color bg = themeProv.isDarkMode
        ? DARK_PAPER_BACKGROUND
        : PAPER_BACKGROUND;

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        backgroundColor: bg,
        appBar: _buildAppBar(tc, bg),
        body: SafeArea(child: _buildBody(fontProv, tc, bg)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeColors tc, Color bg) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: tc.textPrimary),
        onPressed: () => _popWithOrientationInfo(refresh: false),
        tooltip: '뒤로가기',
      ),
      title: const Text(''),
      actions: [
        // IconButton(
        //   icon: Icon(
        //     isLandscape
        //         ? Icons.stay_current_portrait
        //         : Icons.stay_current_landscape,
        //     color: tc.textPrimary,
        //   ),
        //   onPressed: () {
        //     // (선택) 가로/세로 직접 전환 로직
        //   },
        //   tooltip: isLandscape ? '세로 모드로 전환' : '가로 모드로 전환',
        // ),
        IconButton(
          icon: Icon(
            Icons.delete,
            color: TEXT_HIGHLIGHT_COLOR.withOpacity(0.8),
          ),
          onPressed: _isDeleting ? null : () => _deleteDiary(),
          tooltip: '일기 삭제',
        ),
        IconButton(
          icon: Icon(Icons.text_format, color: tc.textPrimary),
          onPressed: () => FontSettingsDialog.show(context),
          tooltip: '폰트 설정',
        ),
        IconButton(
          icon: Icon(Icons.edit, color: tc.textPrimary),
          onPressed: () => _editDiary(),
          padding: const EdgeInsets.only(left: 10, right: 20),
          tooltip: '일기 수정',
        ),
      ],
    );
  }

  Widget _buildBody(FontProvider fontProv, ThemeColors tc, Color bg) =>
      SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: _horizontalPadding,
          vertical: _verticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(fontProv, tc),
            const SizedBox(height: 24),
            _buildTitle(fontProv, tc),
            const SizedBox(height: 24),
            _buildContent(fontProv, tc, bg),
            const SizedBox(height: 24),
            _buildCharacterCount(fontProv, tc),
            const SizedBox(height: 24),
          ],
        ),
      );

  Widget _buildHeader(FontProvider fontProv, ThemeColors tc) {
    final createdAt = _diary.createdAt;
    return Row(
      children: [
        // 왼쪽 - 시간 정보
        Icon(
          Icons.schedule,
          size: 16,
          color: tc.textSecondary.withOpacity(0.7),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${createdAt.year}년 ${createdAt.month}월 ${createdAt.day}일 '
            '${createdAt.hour.toString().padLeft(2, '0')}:'
            '${createdAt.minute.toString().padLeft(2, '0')} 작성',
            style: fontProv.getTextStyle(
              customSize: 12,
              color: tc.textSecondary.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // 오른쪽 - 일기 아이콘들
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 날씨 아이콘
            if (_diary.weather.isNotEmpty) ...[
              _buildDiaryIcon('weather', _diary.weather, tc),
              const SizedBox(width: 4),
            ],

            // 감정 아이콘
            if (_diary.emotion.isNotEmpty) ...[
              _buildDiaryIcon('emotion', _diary.emotion, tc),
              const SizedBox(width: 4),
            ],

            // 활동 아이콘
            if (_diary.activityType.isNotEmpty) ...[
              _buildDiaryIcon('activity', _diary.activityType, tc),
              const SizedBox(width: 4),
            ],

            // 사회적 아이콘
            if (_diary.socialContext.isNotEmpty)
              _buildDiaryIcon('social', _diary.socialContext, tc),
          ],
        ),
      ],
    );
  }

  // 개별 아이콘 빌더 (터치 가능)
  Widget _buildDiaryIcon(String category, String value, ThemeColors tc) {
    final iconPath = DiaryConstants.getIconPath(category, value);
    final label = DiaryConstants.getLabel(category, value);

    return Tooltip(
      message: label,
      preferBelow: false,
      child: Container(
        width: 36,
        height: 36,
        // decoration: BoxDecoration(
        //   shape: BoxShape.circle,
        //   color: tc.surface.withOpacity(0.8),
        //   border: Border.all(
        //     color: tc.textSecondary.withOpacity(0.2),
        //     width: 1,
        //   ),
        // ),
        alignment: Alignment.center,
        child: iconPath != null
            ? Image.asset(iconPath, width: 24, height: 24)
            : _buildFallbackIcon(category, tc),
      ),
    );
  }

  // 대체 아이콘
  Widget _buildFallbackIcon(String category, ThemeColors tc) {
    IconData iconData;
    switch (category) {
      case 'emotion':
        iconData = Icons.sentiment_satisfied;
        break;
      case 'weather':
        iconData = Icons.wb_sunny;
        break;
      case 'activity':
        iconData = Icons.local_activity;
        break;
      case 'social':
        iconData = Icons.people;
        break;
      default:
        iconData = Icons.help_outline;
    }

    return Icon(iconData, size: 20, color: tc.textSecondary.withOpacity(0.6));
  }

  Widget _buildTitle(FontProvider fontProv, ThemeColors tc) {
    return Text(
      _diary.title,
      style: fontProv.getTextStyle(
        customSize: fontProv.fontSize + 4,
        fontWeight: FontWeight.w700,
        color: tc.textPrimary,
        height: 1.3,
      ),
    );
  }

  Widget _buildContent(FontProvider fontProv, ThemeColors tc, Color bg) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 48),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: SelectableText(
          _diary.content,
          style: fontProv.getTextStyle(
            height: 1.6,
            color: tc.textPrimary,
            customSize: fontProv.fontSize,
          ),
        ),
      );

  Widget _buildCharacterCount(FontProvider fontProv, ThemeColors tc) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: TEXT_HINT_COLOR.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${_diary.content.length}자',
          style: fontProv.getTextStyle(
            customSize: 12,
            color: tc.textSecondary.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
