import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontProvider extends ChangeNotifier {
  // 현재 폰트 설정
  double _fontSize = 16.0;
  String _fontFamily = 'Cafe24Oneprettynight';

  // SharedPreferences 키
  static const String _fontSizeKey = 'font_size';
  static const String _fontFamilyKey = 'font_family';

  // 사용 가능한 폰트 목록
  static const List<Map<String, String>> availableFonts = [
    {'name': '카페24 예쁜밤체', 'family': 'Cafe24Oneprettynight'},
    {'name': '온글립 콘콘체', 'family': 'OngeulipKonKonche'},
    {'name': '고운돋움', 'family': 'GowunDodum'},
    {'name': '학교안심 그림일기체', 'family': 'HakgyoansimGeurimilgi'},
    {'name': '교보손글씨 2024', 'family': 'KyoboHandwriting2024psw'},
    {'name': '온글립 박다현', 'family': 'OngeulipParkDahyun'},
    {'name': '릭스 수박레이디', 'family': 'RixXLadywatermelon'},
    {'name': '교보손글씨 2020', 'family': 'KyoboHandwriting2020pdy'},
    {'name': '조선일보 신문명조', 'family': 'ChosunCentennial'},
  ];

  // Getter
  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;

  // 초기화 (앱 시작 시 호출)
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    _fontSize = prefs.getDouble(_fontSizeKey) ?? _fontSize;
    _fontFamily = prefs.getString(_fontFamilyKey) ?? _fontFamily;

    // UI 업데이트 알림
    notifyListeners();
  }

  // 폰트 크기 변경
  Future<void> setFontSize(double size) async {
    if (_fontSize == size) return; // 같은 값이면 저장하지 않음

    _fontSize = size;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);

    // 🔥 모든 화면에 변경사항 알림!
    notifyListeners();
  }

  // 폰트 패밀리 변경
  Future<void> setFontFamily(String family) async {
    if (_fontFamily == family) return; // 같은 값이면 저장하지 않음

    _fontFamily = family;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontFamilyKey, family);

    // 🔥 모든 화면에 변경사항 알림!
    notifyListeners();
  }

  // 폰트 설정 일괄 변경
  Future<void> updateFontSettings(double size, String family) async {
    bool changed = false;

    if (_fontSize != size) {
      _fontSize = size;
      changed = true;
    }

    if (_fontFamily != family) {
      _fontFamily = family;
      changed = true;
    }

    if (!changed) return;

    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setDouble(_fontSizeKey, size),
      prefs.setString(_fontFamilyKey, family),
    ]);

    // 🔥 모든 화면에 변경사항 알림!
    notifyListeners();
  }

  // TextStyle 생성 헬퍼 메소드
  TextStyle getTextStyle({
    double? customSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontSize: customSize ?? _fontSize,
      fontFamily: _fontFamily.isEmpty ? null : _fontFamily,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  // 제목용 TextStyle (본문보다 4pt 크게)
  TextStyle getTitleTextStyle({
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    return getTextStyle(
      customSize: _fontSize + 4,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color,
      height: height,
    );
  }

  // 폰트 이름을 패밀리로 변환
  String getFontFamilyByName(String name) {
    final font = availableFonts.firstWhere(
      (font) => font['name'] == name,
      orElse: () => {'name': 'Default', 'family': ''},
    );
    return font['family'] ?? '';
  }

  // 폰트 패밀리를 이름으로 변환
  String getFontNameByFamily(String family) {
    final font = availableFonts.firstWhere(
      (font) => font['family'] == family,
      orElse: () => {'name': 'Default', 'family': ''},
    );
    return font['name'] ?? 'Default';
  }
}
