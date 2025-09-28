// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/const/colors.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/screen/home_screen.dart';
import 'package:diaryletter/screen/diary_list_screen.dart';
import 'package:diaryletter/screen/statistics_screen.dart';
import 'package:diaryletter/screen/ai_screen.dart';
import 'package:diaryletter/screen/settings_screen.dart';
import 'package:diaryletter/widgets/diary/screen/diary_write/diary_write_screen.dart';
import 'package:diaryletter/widgets/ads/banner_ad_widget.dart';
import 'package:diaryletter/config/ad_config.dart';
import 'package:diaryletter/config/system_ui_config.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  final ValueNotifier<bool> _todayNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _refreshNotifier = ValueNotifier<bool>(false);

  late final List<Widget> screens = [
    HomeScreen(
      todayNotifier: _todayNotifier,
      refreshNotifier: _refreshNotifier,
    ),
    DiaryListScreen(refreshNotifier: _refreshNotifier),
    StatisticsScreen(refreshNotifier: _refreshNotifier),
    AIScreen(),
    SettingsScreen(),
  ];

  double? _cachedScale;
  double? _cachedScreenWidth;

  double _getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (_cachedScreenWidth == screenWidth && _cachedScale != null) {
      return _cachedScale!;
    }
    const baseWidth = 430.0;
    _cachedScale = screenWidth / baseWidth;
    _cachedScreenWidth = screenWidth;
    return _cachedScale!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedScale = null;
    _cachedScreenWidth = null;

    final themeProv = context.watch<ThemeProvider>();
    SystemUIConfig.setSystemUIOverlay(themeProv.isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final tc = themeProv.colors;

    final scale = _getScaleFactor(context);
    final iconSize = (24.0 * scale).clamp(20.0, 26.0).toDouble();
    final selectedFontSize = (12.0 * scale).clamp(11.0, 14.0).toDouble();
    final unselectedFontSize = (11.0 * scale).clamp(10.0, 13.0).toDouble();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUIConfig.getStatusBarStyle(themeProv.isDarkMode),
      child: Scaffold(
        backgroundColor: tc.surface,
        body: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(index: currentIndex, children: screens),
            ),
            if (currentIndex == 0 || currentIndex == 1)
              Positioned(
                right: 16,
                bottom: AdConfig.fabBottom,
                child: FloatingActionButton(
                  heroTag: 'mainScreenFAB',
                  backgroundColor: tc.accent,
                  onPressed: _createNewDiary,
                  child: const Icon(Icons.edit, color: Colors.white),
                  tooltip: '새 일기 작성',
                  elevation: 6.0,
                ),
              ),
            if (AdConfig.isAdEnabled)
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BannerAdWidget(),
              ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: _onTabTapped,
          selectedItemColor: themeProv.isDarkMode
              ? Colors.amber[600]
              : tc.primary,
          unselectedItemColor: tc.textSecondary,
          iconSize: iconSize,
          selectedLabelStyle: TextStyle(
            fontFamily: 'OngeulipKonKonche',
            fontSize: selectedFontSize,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'OngeulipKonKonche',
            fontSize: unselectedFontSize,
            fontWeight: FontWeight.w400,
          ),
          backgroundColor: themeProv.isDarkMode
              ? DARK_BACKGROUND_COLOR
              : BACKGROUND_COLOR,
          elevation: 8.0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: '달력',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              activeIcon: Icon(Icons.book),
              label: '일기',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: '통계',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_outlined),
              activeIcon: Icon(Icons.smart_toy),
              label: 'AI',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: '설정',
            ),
          ],
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() => currentIndex = index);
  }

  void _createNewDiary() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => DiaryWriteScreen(selectedDate: DateTime.now()),
      ),
    );
    if (result?['refresh'] == true) {
      _refreshNotifier.value = !_refreshNotifier.value;
    }
  }
}
