// lib/widgets/diary/screen/diary_write/diary_write_screen.dart

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:diaryletter/const/colors.dart';
import 'package:diaryletter/model/diary_model.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/widgets/ui/font_settings_dialog.dart';
import 'package:diaryletter/widgets/diary/screen/diary_write/components/diary_field_selector.dart';
import 'package:diaryletter/const/diary_option.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiaryWriteScreen extends StatefulWidget {
  final DateTime selectedDate;
  final DiaryModel? editingDiary;

  const DiaryWriteScreen({
    required this.selectedDate,
    this.editingDiary,
    Key? key,
  }) : super(key: key);

  @override
  State<DiaryWriteScreen> createState() => _DiaryWriteScreenState();
}

class _DiaryWriteScreenState extends State<DiaryWriteScreen>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  final _contentCtl = TextEditingController();
  final _scrollCtl = ScrollController();

  bool _isSaving = false;
  late DiarySelections _selections;
  late ConfettiController _confettiController;

  // 자동 저장 관련 (새 작성 모드에서만 사용)
  Timer? _autoSaveTimer;
  bool _hasUnsavedChanges = false;
  bool _isAutoSaving = false; // 실제 저장 중일 때만 true
  String _lastSavedContent = '';
  bool _hasAskedForRestore = false; // 복원 다이얼로그를 이미 보여줬는지 체크

  bool _isNavigating = false; // ✅ 화면 전환 중인지 체크
  bool _isSaveCompleted = false; // ✅ 정식 저장 완료 여부

  static const Duration _autoSaveDelay = Duration(seconds: 3);

  // 수정 모드인지 확인
  bool get _isEditMode => widget.editingDiary != null;

  // 임시 저장 기능 활성화 여부 (새 작성 모드에서만)
  bool get _shouldUseAutoSave => !_isEditMode;

  @override
  void initState() {
    super.initState();

    debugPrint('🚀 DiaryWriteScreen 초기화 - 수정모드: $_isEditMode');

    // ✅ Confetti 컨트롤러 초기화 (2.0초)
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 2000),
    );

    // 수정 모드가 아닌 경우에만 앱 생명주기 감지
    if (_shouldUseAutoSave) {
      WidgetsBinding.instance.addObserver(this);
    }

    // 이 화면에서는 가로모드도 허용
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (_isEditMode) {
      // 수정 모드: 기존 데이터 로드
      _titleCtl.text = widget.editingDiary!.title;
      _contentCtl.text = widget.editingDiary!.content;
      _selections = DiarySelections(
        emotion: widget.editingDiary!.emotion,
        weather: widget.editingDiary!.weather,
        socialContext: widget.editingDiary!.socialContext,
        activityType: widget.editingDiary!.activityType,
      );
    } else {
      // 새 작성 모드: 빈 상태로 시작
      _selections = DiarySelections(
        emotion: '',
        weather: '',
        socialContext: '',
        activityType: '',
      );

      // 임시 저장된 데이터 복원 확인
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAutoSavedData();
      });
    }

    // 새 작성 모드에서만 텍스트 변경 감지
    if (_shouldUseAutoSave) {
      _titleCtl.addListener(_onTextChanged);
      _contentCtl.addListener(_onTextChanged);
    }

    _updateLastSavedContent();
  }

  @override
  void dispose() {
    _confettiController.dispose();

    if (_shouldUseAutoSave) {
      WidgetsBinding.instance.removeObserver(this);
      _autoSaveTimer?.cancel();
      _titleCtl.removeListener(_onTextChanged);
      _contentCtl.removeListener(_onTextChanged);
    }

    // 세로모드만 다시 허용
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _titleCtl.dispose();
    _contentCtl.dispose();
    _scrollCtl.dispose();
    super.dispose();
  }

  // 앱 생명주기 변화 감지 (새 작성 모드에서만)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!_shouldUseAutoSave) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // 앱이 백그라운드로 갈 때 즉시 저장
      _saveToLocalImmediately();
    }
  }

  // 텍스트 변경 감지 (새 작성 모드에서만)
  void _onTextChanged() {
    if (!_shouldUseAutoSave) return;
    if (_isSaveCompleted) return; // ✅ 정식 저장 이후에는 무시

    final currentContent =
        '${_titleCtl.text}|${_contentCtl.text}|${_selections.emotion}|${_selections.weather}|${_selections.socialContext}|${_selections.activityType}';
    if (currentContent != _lastSavedContent) {
      if (mounted) {
        setState(() => _hasUnsavedChanges = true);
      }

      // 기존 타이머 취소하고 새로 시작 (debounce)
      _autoSaveTimer?.cancel();
      _autoSaveTimer = Timer(_autoSaveDelay, () {
        _saveToLocalImmediately();
      });
    }
  }

  // 현재 저장된 내용 업데이트
  void _updateLastSavedContent() {
    _lastSavedContent =
        '${_titleCtl.text}|${_contentCtl.text}|${_selections.emotion}|${_selections.weather}|${_selections.socialContext}|${_selections.activityType}';
  }

  // 로컬 임시 저장 키 생성
  String get _autoSaveKey {
    final dateStr =
        '${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}';
    return 'diary_autosave_$dateStr';
  }

  // 즉시 로컬 저장 (새 작성 모드에서만)
  Future<void> _saveToLocalImmediately() async {
    if (!_shouldUseAutoSave || !_hasUnsavedChanges) return;
    if (_isSaveCompleted) return; // ✅ 정식 저장 이후에는 임시저장 금지

    if (mounted) {
      setState(() => _isAutoSaving = true);
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // 저장할 데이터가 모두 비어있으면 기존 임시 저장 데이터 삭제
      if (_titleCtl.text.trim().isEmpty &&
          _contentCtl.text.trim().isEmpty &&
          _selections.emotion.isEmpty &&
          _selections.weather.isEmpty &&
          _selections.socialContext.isEmpty &&
          _selections.activityType.isEmpty) {
        await prefs.remove(_autoSaveKey);
        if (mounted) {
          setState(() {
            _hasUnsavedChanges = false;
            _isAutoSaving = false;
          });
        }
        return;
      }

      final autoSaveData = {
        'title': _titleCtl.text,
        'content': _contentCtl.text,
        'emotion': _selections.emotion,
        'weather': _selections.weather,
        'socialContext': _selections.socialContext,
        'activityType': _selections.activityType,
        'savedAt': DateTime.now().toIso8601String(),
        'sessionId': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      final jsonString = jsonEncode(autoSaveData);
      await prefs.setString(_autoSaveKey, jsonString);

      debugPrint('💾 자동 저장 완료');

      // 최소 500ms 동안 "저장 중..." 표시
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false;
          _isAutoSaving = false;
        });
        _updateLastSavedContent();
      }
    } catch (e) {
      debugPrint('❌ 자동 저장 실패: $e');
      if (mounted) {
        setState(() => _isAutoSaving = false);
      }
    }
  }

  // 임시 저장된 데이터 불러오기 (새 작성 모드에서만)
  Future<void> _loadAutoSavedData() async {
    if (!_shouldUseAutoSave || _hasAskedForRestore) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDataStr = prefs.getString(_autoSaveKey);

      if (savedDataStr != null) {
        final savedData = jsonDecode(savedDataStr) as Map<String, dynamic>;

        // 의미있는 내용이 있는 경우에만 복원 다이얼로그 표시
        if (_hasSignificantContent(savedData)) {
          debugPrint('🔄 임시 저장된 데이터 발견');
          _hasAskedForRestore = true;
          final shouldRestore = await _showRestoreDialog(savedData);

          if (shouldRestore && mounted) {
            if (mounted) {
              setState(() {
                _titleCtl.text = savedData['title'] ?? '';
                _contentCtl.text = savedData['content'] ?? '';
                _selections = DiarySelections(
                  emotion: savedData['emotion'] ?? '',
                  weather: savedData['weather'] ?? '',
                  socialContext: savedData['socialContext'] ?? '',
                  activityType: savedData['activityType'] ?? '',
                );
              });
              _updateLastSavedContent();
            }
          } else {
            await prefs.remove(_autoSaveKey);
          }
        } else {
          await prefs.remove(_autoSaveKey);
        }
      }
    } catch (e) {
      debugPrint('❌ 임시 저장 데이터 불러오기 실패: $e');
    }
  }

  // 의미있는 내용이 있는지 확인
  bool _hasSignificantContent(Map<String, dynamic> data) {
    final title = (data['title'] ?? '').toString().trim();
    final content = (data['content'] ?? '').toString().trim();
    final hasSelections =
        (data['emotion'] ?? '').toString().isNotEmpty ||
        (data['weather'] ?? '').toString().isNotEmpty ||
        (data['socialContext'] ?? '').toString().isNotEmpty ||
        (data['activityType'] ?? '').toString().isNotEmpty;

    return title.length > 2 || content.length > 5 || hasSelections;
  }

  // 복원 확인 다이얼로그
  Future<bool> _showRestoreDialog(Map<String, dynamic> savedData) async {
    final themeProv = context.read<ThemeProvider>();
    final bg = themeProv.isDarkMode ? DARK_BACKGROUND : PAPER_BACKGROUND;

    final savedAt = DateTime.tryParse(savedData['savedAt'] ?? '');
    final savedTimeStr = savedAt != null
        ? '${savedAt.month}/${savedAt.day} ${savedAt.hour.toString().padLeft(2, '0')}:${savedAt.minute.toString().padLeft(2, '0')}'
        : '알 수 없음';

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: bg,
            title: Text(
              '임시 저장된 내용이 있습니다.',
              style: TextStyle(color: themeProv.colors.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '이전에 작성하던 내용을 이어서 작성하시겠습니까?',
                  style: TextStyle(color: themeProv.colors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  '저장 시간: $savedTimeStr',
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProv.colors.textSecondary,
                  ),
                ),
                if (savedData['title']?.toString().isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    '제목: ${savedData['title']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProv.colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  '새로 작성',
                  style: TextStyle(color: themeProv.colors.textPrimary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  '이어서 작성',
                  style: TextStyle(color: themeProv.colors.textPrimary),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// 시스템 뒤로가기 처리
  Future<bool> _handleWillPop() async {
    await _handleBackPress();
    return false;
  }

  /// 뒤로가기 처리 통합
  Future<void> _handleBackPress() async {
    // 수정 모드에서는 임시 저장 없이 기존 로직
    if (_isEditMode) {
      _showExitDialog(context.read<ThemeProvider>());
      return;
    }

    // 새 작성 모드에서는 임시 저장 옵션 포함
    _showExitDialogWithAutoSave(context.read<ThemeProvider>());
  }

  /// 팝할 때 가로모드 여부와 새로고침 여부를 함께 전달
  void _popWithOrientationInfo({required bool refresh}) async {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    Navigator.pop(context, {'refresh': refresh, 'wasLandscape': isLandscape});
  }

  @override
  Widget build(BuildContext context) {
    final fontProv = context.watch<FontProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final tc = themeProv.colors;
    final bg = themeProv.isDarkMode ? DARK_PAPER_BACKGROUND : PAPER_BACKGROUND;

    const hPad = 16.0, vPad = 16.0;

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Stack(
        children: [
          // 메인 Scaffold
          Scaffold(
            backgroundColor: bg,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: bg,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(Icons.close, color: tc.textPrimary),
                onPressed: _handleBackPress,
                tooltip: '취소',
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEditMode
                          ? '${widget.selectedDate.month}월 ${widget.selectedDate.day}일 일기 수정'
                          : '${widget.selectedDate.month}월 ${widget.selectedDate.day}일 일기',
                      style: TextStyle(
                        color: tc.textPrimary,
                        fontSize: fontProv.fontSize,
                        fontFamily: fontProv.fontFamily.isEmpty
                            ? null
                            : fontProv.fontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // 임시 저장 상태 표시 (새 작성 모드에서만)
                  if (_shouldUseAutoSave && _isAutoSaving)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '저장 중...',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.text_format, color: tc.textPrimary),
                  onPressed: () => FontSettingsDialog.show(context),
                  tooltip: '폰트 설정',
                ),
                TextButton(
                  onPressed: _isSaving ? null : _saveDiary,
                  child: _isSaving
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: tc.primary,
                          ),
                        )
                      : Text(
                          _isEditMode ? '수정' : '저장',
                          style: TextStyle(
                            color: tc.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: fontProv.fontSize,
                            fontFamily: fontProv.fontFamily.isEmpty
                                ? null
                                : fontProv.fontFamily,
                          ),
                        ),
                ),
              ],
            ),
            body: SafeArea(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    controller: _scrollCtl,
                    padding: const EdgeInsets.symmetric(
                      horizontal: hPad,
                      vertical: vPad,
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _titleCtl,
                          decoration: InputDecoration(
                            hintText: '제목을 입력하세요',
                            hintStyle: TextStyle(color: tc.textSecondary),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                            ),
                          ),
                          style: fontProv.getTitleTextStyle(
                            color: tc.textPrimary,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? '제목을 입력해주세요'
                              : null,
                        ),
                        Divider(color: tc.textSecondary.withOpacity(0.9)),
                        const SizedBox(height: 16),
                        DiaryFieldSelector(
                          selections: _selections,
                          onChanged: (sel) {
                            if (mounted) {
                              setState(() => _selections = sel);
                              if (_shouldUseAutoSave && !_isSaveCompleted) {
                                _onTextChanged(); // ✅ 저장 완료 전까지만 자동저장 트리거
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        Container(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height * 0.4,
                          ),
                          child: TextFormField(
                            controller: _contentCtl,
                            maxLines: null,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText: '오늘 있었던 일을 자유롭게 써보세요...',
                              hintStyle: TextStyle(color: tc.textSecondary),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: fontProv.getTextStyle(
                              height: 1.5,
                              color: tc.textPrimary,
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? '내용을 입력해주세요'
                                : null,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Confetti 효과 (새 작성 모드에서만, 화면 전환 중이 아닐 때만)
          if (!_isEditMode && !_isNavigating) ...[
            Align(
              alignment: Alignment(-1.0, -0.5),
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -pi / 4, // 오른쪽 위로
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.05,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                ],
              ),
            ),
            Align(
              alignment: Alignment(1.0, -0.5),
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -3 * pi / 4, // 왼쪽 위로
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.05,
                shouldLoop: false,
                colors: const [
                  Colors.purple,
                  Colors.yellow,
                  Colors.red,
                  Colors.cyan,
                ],
              ),
            ),
          ],
          // ✅ 화면 전환 시 페이드아웃
          if (_isNavigating)
            AnimatedOpacity(
              opacity: 0.0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                color: bg,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
        ],
      ),
    );
  }

  /// 수정 모드 취소 다이얼로그 (기존)
  void _showExitDialog(ThemeProvider themeProv) {
    FocusScope.of(context).unfocus();
    final bg = themeProv.isDarkMode ? DARK_BACKGROUND : PAPER_BACKGROUND;

    if (_titleCtl.text.isNotEmpty || _contentCtl.text.isNotEmpty) {
      showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: bg,
          title: Text(
            '수정 취소',
            style: TextStyle(
              color: themeProv.colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            '수정 중인 내용은 저장되지 않습니다.\n정말 나가시겠습니까?',
            style: TextStyle(color: themeProv.colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(
                '계속 수정',
                style: TextStyle(color: themeProv.colors.textPrimary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(c);
                _popWithOrientationInfo(refresh: false);
              },
              child: const Text('나가기', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      _popWithOrientationInfo(refresh: false);
    }
  }

  /// 새 작성 모드 취소 다이얼로그 (임시 저장 옵션 포함)
  void _showExitDialogWithAutoSave(ThemeProvider themeProv) {
    FocusScope.of(context).unfocus();
    final bg = themeProv.isDarkMode ? DARK_BACKGROUND : PAPER_BACKGROUND;

    final hasContent =
        _titleCtl.text.isNotEmpty ||
        _contentCtl.text.isNotEmpty ||
        _selections.emotion.isNotEmpty ||
        _selections.weather.isNotEmpty ||
        _selections.socialContext.isNotEmpty ||
        _selections.activityType.isNotEmpty;

    if (hasContent) {
      showDialog<String>(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: bg,
          title: Text(
            '작성 취소',
            style: TextStyle(
              color: themeProv.colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            '작성 중인 내용을 어떻게 하시겠습니까?',
            style: TextStyle(color: themeProv.colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, 'save'),
              child: const Text(
                '임시 저장 후 나가기',
                style: TextStyle(color: Colors.green),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(c, 'discard'),
              child: const Text('나가기', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ).then((result) async {
        switch (result) {
          case 'save':
            // 임시 저장하고 나가기
            debugPrint('💾 수동 임시 저장 요청');
            await _saveToLocalImmediately();
            _popWithOrientationInfo(refresh: false);
            break;
          case 'discard':
            // 임시 저장 데이터 삭제하고 나가기
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove(_autoSaveKey);
            _popWithOrientationInfo(refresh: false);
            break;
          default:
            // 계속 작성
            break;
        }
      });
    } else {
      _popWithOrientationInfo(refresh: false);
    }
  }

  /// 저장 완료 (수정된 부분)
  Future<void> _saveDiary() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_selections.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '오늘 하루는 어땠는지 선택해주세요!',
            style: TextStyle(color: TEXT_PRIMARY_COLOR),
          ),
          backgroundColor: WARNING_COLOR,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (mounted) {
      setState(() => _isSaving = true);
    }
    try {
      final client = Supabase.instance.client;

      if (_isEditMode) {
        await client
            .from('diary')
            .update({
              'title': _titleCtl.text.trim(),
              'content': _contentCtl.text.trim(),
              'emotion': _selections.emotion,
              'weather': _selections.weather,
              'social_context': _selections.socialContext,
              'activity_type': _selections.activityType,
            })
            .eq('id', widget.editingDiary!.id);
      } else {
        final diary = DiaryModel(
          id: '',
          title: _titleCtl.text.trim(),
          content: _contentCtl.text.trim(),
          date: widget.selectedDate,
          createdAt: DateTime.now(),
          emotion: _selections.emotion,
          weather: _selections.weather,
          socialContext: _selections.socialContext,
          activityType: _selections.activityType,
        );
        await client.from('diary').insert(diary.toJson());
      }

      // 정식 저장 완료 시 임시 저장 데이터 삭제 (새 작성 모드에서만)
      if (_shouldUseAutoSave) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_autoSaveKey);
        debugPrint('🗑️ 임시 저장 데이터 삭제 완료'); // ✅ 로그 추가

        // ✅ 정식 저장 완료 플래그 설정 및 자동저장 타이머 취소
        _isSaveCompleted = true;
        _autoSaveTimer?.cancel();
        debugPrint('🛑 자동저장 기능 비활성화'); // ✅ 로그 추가
      }

      if (!mounted) return;

      // 새 작성 모드에서만 confetti 효과 실행
      if (!_isEditMode) {
        _confettiController.play();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode ? '일기가 수정되었습니다' : '일기가 저장되었습니다',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: SUCCESS_COLOR,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // ✅ 저장 성공 시 화면 전환 처리
      if (!_isEditMode) {
        await _handleSuccessfulSaveNavigation();
      } else {
        _popWithOrientationInfo(refresh: true);
      }
    } catch (e) {
      if (!mounted) return;
      if (mounted) {
        setState(() => _isSaving = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '저장에 실패했습니다\n에러: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  /// ✅ 저장 성공 후 화면 전환 처리 (confetti 2.0초 + 페이드아웃 0.5초)
  Future<void> _handleSuccessfulSaveNavigation() async {
    // 2.0초 후 confetti 중지 및 페이드아웃 시작
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted && !_isNavigating) {
        _confettiController.stop();
        setState(() => _isNavigating = true);
      }
    });

    // 총 2.5초 후 화면 전환 (confetti 2.0초 + 페이드아웃 0.5초)
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      _popWithOrientationInfo(refresh: true);
    }
  }
}
