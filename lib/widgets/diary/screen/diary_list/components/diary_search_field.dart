import 'dart:async';
import 'package:flutter/material.dart';
import 'package:diaryletter/providers/font_provider.dart';

class DiarySearchField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSearchSubmitted;
  final Function(String) onSearchChanged;
  final dynamic themeColors;
  final FontProvider fontProvider;

  const DiarySearchField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onSearchSubmitted,
    required this.onSearchChanged,
    required this.themeColors,
    required this.fontProvider,
  }) : super(key: key);

  @override
  State<DiarySearchField> createState() => _DiarySearchFieldState();
}

class _DiarySearchFieldState extends State<DiarySearchField> {
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // 🔧 수정: 실시간 검색 제거, 빈 텍스트일 때만 초기화
  void _onChanged(String value) {
    _debounceTimer?.cancel();

    // 텍스트가 비어있을 때만 초기화 신호 전송
    if (value.isEmpty) {
      widget.onSearchChanged('');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      autofocus: true,
      style: TextStyle(
        color: widget.themeColors.textPrimary,
        fontFamily: widget.fontProvider.fontFamily.isEmpty
            ? null
            : widget.fontProvider.fontFamily,
      ),
      decoration: InputDecoration(
        hintText: ' 일기 제목이나 내용을 검색하세요...',
        hintStyle: TextStyle(color: widget.themeColors.textSecondary),
        border: InputBorder.none,
      ),
      onSubmitted: widget.onSearchSubmitted, // 🔧 엔터키로만 검색
      onChanged: _onChanged, // 🔧 빈 텍스트일 때만 초기화
    );
  }
}
