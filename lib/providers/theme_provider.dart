import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diaryletter/const/colors.dart';
import 'package:diaryletter/const/theme_colors.dart';

enum AppTheme { pink, green, blue, peach, black }

class ThemeProvider extends ChangeNotifier {
  static const _keyTheme = 'theme';
  static const _keyDarkMode = 'darkMode';

  AppTheme _current = AppTheme.blue;
  bool _isDark = false;

  AppTheme get current => _current;
  bool get isDarkMode => _isDark;
  ThemeColors get colors =>
      _isDark ? _darkMap[_current]! : _lightMap[_current]!;

  static ThemeColors get staticBlackLight => _lightMap[AppTheme.black]!;
  static Map<AppTheme, ThemeColors> get lightMap => _lightMap;
  static Map<AppTheme, ThemeColors> get darkMap => _darkMap;

  /// 🎨 현재 테마의 라이트 ColorScheme 생성
  ColorScheme get lightColorScheme {
    final tc = _lightMap[_current]!;
    return ColorScheme(
      brightness: Brightness.light,
      primary: tc.primary,
      onPrimary: Colors.white,
      secondary: tc.secondary,
      onSecondary: Colors.white,
      surface: tc.surface,
      onSurface: tc.textPrimary,
      background: tc.background,
      onBackground: tc.textPrimary,
      error: ERROR_COLOR,
      onError: Colors.white,
    );
  }

  /// 🌙 현재 테마의 다크 ColorScheme 생성
  ColorScheme get darkColorScheme {
    final tc = _darkMap[_current]!;
    return ColorScheme(
      brightness: Brightness.dark,
      primary: tc.primary,
      onPrimary: tc.textPrimary,
      secondary: tc.secondary,
      onSecondary: tc.textPrimary,
      surface: tc.surface,
      onSurface: tc.textPrimary,
      background: tc.background,
      onBackground: tc.textPrimary,
      error: ERROR_COLOR,
      onError: tc.textPrimary,
    );
  }

  /// 🎨 현재 테마의 라이트 ThemeData 생성
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: lightColorScheme.background,
      cardColor: lightColorScheme.surface,
    );
  }

  /// 🌙 현재 테마의 다크 ThemeData 생성
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: darkColorScheme.background,
      cardColor: darkColorScheme.surface,
    );
  }

  /// 🎨 폰트가 적용된 라이트 ThemeData 생성
  ThemeData getLightThemeWithFont(String? fontFamily) {
    return lightTheme.copyWith(
      textTheme: lightTheme.textTheme.apply(
        fontFamily: fontFamily?.isEmpty == true ? null : fontFamily,
      ),
    );
  }

  /// 🌙 폰트가 적용된 다크 ThemeData 생성
  ThemeData getDarkThemeWithFont(String? fontFamily) {
    return darkTheme.copyWith(
      textTheme: darkTheme.textTheme.apply(
        fontFamily: fontFamily?.isEmpty == true ? null : fontFamily,
      ),
    );
  }

  /// 앱 시작 시 SharedPreferences에서 값 불러오기
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    final storedIdx = prefs.getInt(_keyTheme);
    _current = (storedIdx != null)
        ? AppTheme.values[storedIdx]
        : AppTheme.blue; // 기본 테마

    final storedDark = prefs.getBool(_keyDarkMode);
    _isDark = storedDark ?? false;

    notifyListeners();
  }

  /// 테마 변경 시 저장
  void setTheme(AppTheme theme) {
    if (_current == theme) return;
    _current = theme;
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setInt(_keyTheme, theme.index),
    );
    notifyListeners();
  }

  /// 다크모드 토글 시 저장
  void toggleDarkMode(bool on) {
    if (_isDark == on) return;
    _isDark = on;
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setBool(_keyDarkMode, on),
    );
    notifyListeners();
  }

  // 라이트 모드용 테마 매핑
  static final Map<AppTheme, ThemeColors> _lightMap = {
    AppTheme.pink: const ThemeColors(
      primary: PRIMARY_PINK,
      secondary: SECONDARY_PINK,
      accent: ACCENT_PINK,
      background: BACKGROUND_PINK,
      surface: SURFACE_PINK,
      card: CARD_PINK,
      textPrimary: TEXT_PRIMARY_COLOR,
      textSecondary: TEXT_SECONDARY_COLOR,
    ),
    AppTheme.green: const ThemeColors(
      primary: PRIMARY_GREEN,
      secondary: SECONDARY_GREEN,
      accent: ACCENT_GREEN,
      background: BACKGROUND_GREEN,
      surface: SURFACE_GREEN,
      card: CARD_GREEN,
      textPrimary: TEXT_PRIMARY_COLOR,
      textSecondary: TEXT_SECONDARY_COLOR,
    ),
    AppTheme.blue: const ThemeColors(
      primary: PRIMARY_BLUE,
      secondary: SECONDARY_BLUE,
      accent: ACCENT_BLUE,
      background: BACKGROUND_BLUE,
      surface: SURFACE_BLUE,
      card: CARD_BLUE,
      textPrimary: TEXT_PRIMARY_COLOR,
      textSecondary: TEXT_SECONDARY_COLOR,
    ),
    AppTheme.peach: const ThemeColors(
      primary: PRIMARY_PEACH,
      secondary: SECONDARY_PEACH,
      accent: ACCENT_PEACH,
      background: BACKGROUND_PEACH,
      surface: SURFACE_PEACH,
      card: CARD_PEACH,
      textPrimary: TEXT_PRIMARY_COLOR,
      textSecondary: TEXT_SECONDARY_COLOR,
    ),
    AppTheme.black: const ThemeColors(
      primary: PRIMARY_BLACK,
      secondary: SECONDARY_BLACK,
      accent: ACCENT_BLACK,
      background: BACKGROUND_BLACK,
      surface: SURFACE_BLACK,
      card: CARD_BLACK,
      textPrimary: TEXT_PRIMARY_COLOR,
      textSecondary: TEXT_SECONDARY_COLOR,
    ),
  };

  // 다크 모드용 테마 매핑
  static final Map<AppTheme, ThemeColors> _darkMap = {
    for (var theme in AppTheme.values)
      theme: const ThemeColors(
        primary: DARK_PRIMARY,
        secondary: DARK_SECONDARY,
        accent: DARK_ACCENT,
        background: DARK_BACKGROUND,
        surface: DARK_SURFACE,
        card: DARK_CARD,
        textPrimary: DARK_TEXT,
        textSecondary: DARK_TEXT_SECONDARY,
      ),
  };
}
