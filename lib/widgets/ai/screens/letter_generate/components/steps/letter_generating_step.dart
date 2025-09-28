// components/steps/letter_generating_step.dart
import 'package:flutter/material.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/providers/font_provider.dart';

class LetterGeneratingStep extends StatefulWidget {
  final String userName;
  final int selectedDiariesCount;
  final AnimationController pulseAnimation;
  final AnimationController progressAnimation;
  final ThemeProvider themeProv;
  final FontProvider fontProv;

  const LetterGeneratingStep({
    Key? key,
    required this.userName,
    required this.selectedDiariesCount,
    required this.pulseAnimation,
    required this.progressAnimation,
    required this.themeProv,
    required this.fontProv,
  }) : super(key: key);

  @override
  _LetterGeneratingStepState createState() => _LetterGeneratingStepState();
}

class _LetterGeneratingStepState extends State<LetterGeneratingStep> {
  int _currentMessageIndex = 0;

  // 생성 진행 상태 메시지들
  final List<String> _generationMessages = [
    '일기 내용을 분석하고 있어요...',
    '감정의 흐름을 파악하고 있어요...',
    '따뜻한 메시지를 준비하고 있어요...',
    '편지를 작성하고 있어요...',
  ];

  @override
  void initState() {
    super.initState();
    _startMessageCycle();
  }

  void _startMessageCycle() {
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentMessageIndex =
              (_currentMessageIndex + 1) % _generationMessages.length;
        });
        _startMessageCycle();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: widget.pulseAnimation, curve: Curves.easeInOut),
    );

    final progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.progressAnimation,
        curve: Curves.easeInOut,
      ),
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(scale: pulseAnimation, child: _buildAnimatedIcon()),
          SizedBox(height: 32),
          _buildMainMessage(),
          SizedBox(height: 24),
          _buildCurrentMessage(),
          SizedBox(height: 32),
          _buildProgressBar(progressAnimation),
          SizedBox(height: 16),
          _buildSubMessage(),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            widget.themeProv.colors.primary.withOpacity(0.2),
            Colors.pink[100]!.withOpacity(0.3),
          ],
        ),
      ),
      child: Icon(
        Icons.auto_awesome,
        size: 64,
        color: widget.themeProv.isDarkMode
            ? Colors.white70
            : widget.themeProv.colors.primary,
      ),
    );
  }

  Widget _buildMainMessage() {
    return Text(
      '${widget.userName}님의 마음이\n편지로 꽃피고 있어요...',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: widget.themeProv.colors.textPrimary,
        fontFamily: widget.fontProv.fontFamily.isEmpty
            ? null
            : widget.fontProv.fontFamily,
        height: 1.3,
      ),
    );
  }

  Widget _buildCurrentMessage() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: Text(
        _generationMessages[_currentMessageIndex],
        key: ValueKey(_currentMessageIndex),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: widget.themeProv.colors.textSecondary,
          fontFamily: widget.fontProv.fontFamily.isEmpty
              ? null
              : widget.fontProv.fontFamily,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildProgressBar(Animation<double> progressAnimation) {
    return Container(
      width: 250,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
      child: AnimatedBuilder(
        animation: progressAnimation,
        builder: (context, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progressAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.themeProv.colors.primary,
                    widget.themeProv.colors.primary.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubMessage() {
    return Text(
      '${widget.selectedDiariesCount}일의 소중한 추억들이\n따뜻한 이야기로 엮이고 있어요',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: widget.themeProv.colors.textSecondary,
        fontFamily: widget.fontProv.fontFamily.isEmpty
            ? null
            : widget.fontProv.fontFamily,
        height: 1.4,
      ),
    );
  }
}
