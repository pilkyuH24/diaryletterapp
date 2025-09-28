// lib/screen/letter_generate_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/model/diary_model.dart';
import 'package:diaryletter/widgets/ai/screens/letter_generate/services/letter_generation_service.dart';
import 'package:diaryletter/widgets/ai/screens/letter_generate/components/loading/loading_state_widget.dart';
import 'package:diaryletter/widgets/ai/screens/letter_generate/components/loading/error_state_widget.dart';
import 'package:diaryletter/widgets/ai/screens/letter_generate/components/steps/diary_selection_step.dart';
import 'package:diaryletter/widgets/ai/screens/letter_generate/components/steps/letter_generating_step.dart';
import 'package:diaryletter/widgets/ai/screens/letter_generate/components/steps/letter_result_step.dart';
import 'package:diaryletter/widgets/ai/screens/letter_generate/components/widgets/progress_indicator_widget.dart';

class LetterGenerateScreen extends StatefulWidget {
  final String userName;

  const LetterGenerateScreen({Key? key, required this.userName})
    : super(key: key);

  @override
  _LetterGenerateScreenState createState() => _LetterGenerateScreenState();
}

class _LetterGenerateScreenState extends State<LetterGenerateScreen>
    with TickerProviderStateMixin {
  // 상태 변수들
  late LetterGenerationService _service;
  List<DiaryModel> _availableDiaries = [];
  List<DiaryModel> _selectedDiaries = [];
  bool _isLoadingDiaries = true;
  bool _isGeneratingLetter = false;
  String? _generatedLetter;
  String? _generatedTitle;
  String? _errorMessage;
  int _currentStep = 0;

  // 애니메이션 컨트롤러들
  late AnimationController _progressController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _service = LetterGenerationService();
    _initAnimations();
    _loadAvailableDiaries();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _initAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _loadAvailableDiaries() async {
    final result = await _service.loadAvailableDiaries();
    if (!mounted) return;
    setState(() {
      _availableDiaries = result.diaries;
      _isLoadingDiaries = false;
      _errorMessage = result.errorMessage;
    });
    if (_availableDiaries.isNotEmpty) _autoSelectRecentDiaries();
  }

  void _autoSelectRecentDiaries() {
    final selected = _service.autoSelectRecentDiaries(_availableDiaries);
    setState(() => _selectedDiaries = selected);
  }

  void _toggleDiarySelection(DiaryModel diary) {
    final result = _service.toggleDiarySelection(_selectedDiaries, diary);
    setState(() => _selectedDiaries = result.selectedDiaries);
    if (result.errorMessage != null) {
      _showSnackBar(result.errorMessage!, isError: true);
    }
  }

  Future<void> _generateLetter() async {
    if (_selectedDiaries.isEmpty) {
      _showSnackBar('분석할 일기를 선택해주세요!', isError: true);
      return;
    }

    setState(() {
      _isGeneratingLetter = true;
      _currentStep = 1;
      _errorMessage = null;
    });
    _progressController.forward();

    final result = await _service.generateLetter(
      _selectedDiaries,
      widget.userName,
    );

    if (!mounted) return;
    setState(() {
      _isGeneratingLetter = false;
      if (result.success) {
        _generatedLetter = result.content;
        _generatedTitle = result.title;
        _currentStep = 2;
        _showSnackBar('편지가 완성되었어요!');
      } else {
        _currentStep = 0;
        _errorMessage = result.errorMessage;
      }
    });
    _progressController.reset();
  }

  Future<void> _saveLetter() async {
    if (_generatedTitle == null || _generatedLetter == null) return;
    final result = await _service.saveLetter(
      _generatedTitle!,
      _generatedLetter!,
      _selectedDiaries,
    );

    if (result.success) {
      _showSnackBar('편지가 성공적으로 저장되었어요!');
      Navigator.pop(context, true);
    } else {
      _showSnackBar(result.errorMessage!, isError: true);
    }
  }

  void _resetToSelection() {
    setState(() {
      _currentStep = 0;
      _generatedLetter = null;
      _generatedTitle = null;
      _errorMessage = null;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final fontProv = context.watch<FontProvider>();

    return Scaffold(
      backgroundColor: themeProv.colors.background,
      appBar: _buildAppBar(themeProv, fontProv),
      body: SafeArea(child: _buildBody(themeProv, fontProv)),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ThemeProvider themeProv,
    FontProvider fontProv,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        '${widget.userName}님의 편지',
        style: TextStyle(
          color: themeProv.colors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          fontFamily: fontProv.fontFamily.isEmpty ? null : fontProv.fontFamily,
        ),
      ),
      iconTheme: IconThemeData(color: themeProv.colors.textPrimary),
      centerTitle: true,
    );
  }

  Widget _buildBody(ThemeProvider themeProv, FontProvider fontProv) {
    if (_isLoadingDiaries) {
      return LoadingStateWidget(
        userName: widget.userName,
        pulseAnimation: _pulseController,
        themeProv: themeProv,
        fontProv: fontProv,
      );
    }

    if (_errorMessage != null && _currentStep == 0) {
      return ErrorStateWidget(
        errorMessage: _errorMessage!,
        onRetry: _loadAvailableDiaries,
        onReset: _resetToSelection,
        themeProv: themeProv,
        fontProv: fontProv,
      );
    }

    return Column(
      children: [
        ProgressIndicatorWidget(
          currentStep: _currentStep,
          themeProv: themeProv,
          fontProv: fontProv,
        ),
        Expanded(child: _buildCurrentStep(themeProv, fontProv)),
      ],
    );
  }

  Widget _buildCurrentStep(ThemeProvider themeProv, FontProvider fontProv) {
    switch (_currentStep) {
      case 0:
        return DiarySelectionStep(
          availableDiaries: _availableDiaries,
          selectedDiaries: _selectedDiaries,
          userName: widget.userName,
          onDiaryToggle: _toggleDiarySelection,
          onGenerateLetter: _generateLetter,
          themeProv: themeProv,
          fontProv: fontProv,
        );
      case 1:
        return LetterGeneratingStep(
          userName: widget.userName,
          selectedDiariesCount: _selectedDiaries.length,
          pulseAnimation: _pulseController,
          progressAnimation: _progressController,
          themeProv: themeProv,
          fontProv: fontProv,
        );
      case 2:
        return LetterResultStep(
          title: _generatedTitle,
          content: _generatedLetter,
          onSave: _saveLetter,
          onRegenerate: _resetToSelection,
          themeProv: themeProv,
          fontProv: fontProv,
        );
      default:
        return DiarySelectionStep(
          availableDiaries: _availableDiaries,
          selectedDiaries: _selectedDiaries,
          userName: widget.userName,
          onDiaryToggle: _toggleDiarySelection,
          onGenerateLetter: _generateLetter,
          themeProv: themeProv,
          fontProv: fontProv,
        );
    }
  }
}
