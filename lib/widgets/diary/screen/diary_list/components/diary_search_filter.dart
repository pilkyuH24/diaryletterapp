// lib/widgets/diary/screen/diary_list/components/diary_search_filter.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/const/theme_colors.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/providers/font_provider.dart';
import 'package:diaryletter/const/diary_option.dart';
import 'package:diaryletter/model/diary_filter.dart';
import 'package:diaryletter/model/diary_model.dart';
import 'package:diaryletter/widgets/diary/services/diary_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 🔧 전체 화면 필터 (오버플로우 해결)
class FilterScreen extends StatefulWidget {
  final DiaryFilter currentFilter;
  final Map<String, int> emotionStats;

  const FilterScreen({
    Key? key,
    required this.currentFilter,
    required this.emotionStats,
  }) : super(key: key);

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late DiaryFilter _tempFilter;
  FilteredStatistics _currentStats = FilteredStatistics.empty();
  bool _isLoadingStats = false;
  List<int> _availableYears = [];

  @override
  void initState() {
    super.initState();
    _tempFilter = widget.currentFilter;
    _loadAvailableYears();
    _loadStatistics();
  }

  List<int> get _availableMonths {
    return List.generate(12, (index) => index + 1);
  }

  /// 🔧 실제 데이터에서 사용 가능한 년도만 가져오기
  Future<void> _loadAvailableYears() async {
    try {
      final response = await Supabase.instance.client
          .from('diary')
          .select('date')
          .order('date', ascending: false);

      final years = <int>{};
      for (final row in response as List) {
        final dateStr = row['date'] as String;
        if (dateStr.length >= 4) {
          final year = int.tryParse(dateStr.substring(0, 4));
          if (year != null) {
            years.add(year);
          }
        }
      }

      if (mounted) {
        setState(() {
          _availableYears = years.toList()
            ..sort((a, b) => b.compareTo(a)); // 최신순
        });
      }
    } catch (e) {
      debugPrint('년도 로딩 실패: $e');
      // fallback으로 현재 년도와 작년 사용
      final currentYear = DateTime.now().year;
      if (mounted) {
        setState(() {
          _availableYears = [currentYear, currentYear - 1];
        });
      }
    }
  }

  /// 🔧 현재 필터 조건에 따른 실시간 통계 로딩
  Future<void> _loadStatistics() async {
    setState(() => _isLoadingStats = true);

    try {
      final stats = await DiaryService.getFilteredStatistics(_tempFilter);
      if (mounted) {
        setState(() {
          _currentStats = stats;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      debugPrint('📊 통계 로딩 실패: $e');
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  /// 🔧 필터 변경시 통계 업데이트
  void _updateFilter(DiaryFilter newFilter) {
    setState(() => _tempFilter = newFilter);
    _loadStatistics(); // 필터 변경시마다 통계 업데이트
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final fontProv = context.watch<FontProvider>();
    final tc = themeProv.colors;

    return Scaffold(
      backgroundColor: tc.background,
      appBar: AppBar(
        backgroundColor: tc.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: tc.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '일기 필터',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: tc.textPrimary,
            fontFamily: fontProv.fontFamily.isEmpty
                ? null
                : fontProv.fontFamily,
          ),
        ),
        actions: [
          // 🔧 고정된 크기의 actions 영역 (깜빡임 방지)
          Container(
            width: 140, // 고정 폭 설정
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 총 개수 표시 (고정 공간)
                Container(
                  width: 60,
                  alignment: Alignment.center,
                  child: !_isLoadingStats
                      ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: tc.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_currentStats.totalCount}개',
                            style: TextStyle(
                              fontSize: 11,
                              color: tc.primary,
                              fontWeight: FontWeight.w600,
                              fontFamily: fontProv.fontFamily.isEmpty
                                  ? null
                                  : fontProv.fontFamily,
                            ),
                          ),
                        )
                      : SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              tc.primary,
                            ),
                          ),
                        ),
                ),
                SizedBox(width: 4),
                // 초기화 버튼 (고정 공간)
                Container(
                  width: 60,
                  child: _tempFilter.hasFilter
                      ? TextButton(
                          onPressed: () {
                            _updateFilter(DiaryFilter.empty);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size(0, 32),
                          ),
                          child: Text(
                            '초기화',
                            style: TextStyle(
                              fontSize: 12,
                              color: tc.primary,
                              fontFamily: fontProv.fontFamily.isEmpty
                                  ? null
                                  : fontProv.fontFamily,
                            ),
                          ),
                        )
                      : SizedBox(), // 빈 공간 유지
                ),
                SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔧 빠른 기간 선택
                  _buildQuickPeriodSection(tc, fontProv),

                  SizedBox(height: 20),

                  // 🔧 년도/월 선택
                  _buildDateSection(tc, fontProv),

                  SizedBox(height: 24),

                  // 🔧 감정별 필터 (실시간 count 표시)
                  _buildFilterSection(
                    '감정',
                    Icons.mood,
                    DiaryOptions.emotions.map((option) {
                      final count =
                          _currentStats.emotionCounts[option.value] ?? 0;
                      return _FilterOption(
                        value: option.value,
                        label: option.text,
                        count: count,
                        isSelected: _tempFilter.emotion == option.value,
                        isEnabled: count > 0,
                        color: DiaryConstants.getColor('emotion', option.value),
                      );
                    }).toList(),
                    (value) => _updateFilter(
                      _tempFilter.copyWith(
                        emotion: _tempFilter.emotion == value ? null : value,
                        clearEmotion: _tempFilter.emotion == value,
                      ),
                    ),
                    tc,
                    fontProv,
                  ),

                  SizedBox(height: 24),

                  // 🔧 함께한 사람별 필터 (실시간 count 표시)
                  _buildFilterSection(
                    '함께한 사람',
                    Icons.people,
                    DiaryOptions.socialContexts.map((option) {
                      final count =
                          _currentStats.socialCounts[option.value] ?? 0;
                      return _FilterOption(
                        value: option.value,
                        label: option.text,
                        count: count,
                        isSelected: _tempFilter.socialContext == option.value,
                        isEnabled: count > 0,
                        color: DiaryConstants.getColor('social', option.value),
                      );
                    }).toList(),
                    (value) => _updateFilter(
                      _tempFilter.copyWith(
                        socialContext: _tempFilter.socialContext == value
                            ? null
                            : value,
                        clearSocial: _tempFilter.socialContext == value,
                      ),
                    ),
                    tc,
                    fontProv,
                  ),

                  SizedBox(height: 24),

                  // 🔧 활동별 필터 (실시간 count 표시)
                  _buildFilterSection(
                    '활동',
                    Icons.local_activity,
                    DiaryOptions.activityTypes.map((option) {
                      final count =
                          _currentStats.activityCounts[option.value] ?? 0;
                      return _FilterOption(
                        value: option.value,
                        label: option.text,
                        count: count,
                        isSelected: _tempFilter.activityType == option.value,
                        isEnabled: count > 0,
                        color: DiaryConstants.getColor(
                          'activity',
                          option.value,
                        ),
                      );
                    }).toList(),
                    (value) => _updateFilter(
                      _tempFilter.copyWith(
                        activityType: _tempFilter.activityType == value
                            ? null
                            : value,
                        clearActivity: _tempFilter.activityType == value,
                      ),
                    ),
                    tc,
                    fontProv,
                  ),

                  SizedBox(height: 24),

                  // 🔧 날씨별 필터 (실시간 count 표시) - 기존 4개만
                  _buildWeatherFilterSection(tc, fontProv),

                  SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // 적용 버튼 (하단 고정)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tc.background,
              border: Border(
                top: BorderSide(color: tc.textSecondary.withOpacity(0.1)),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoadingStats
                    ? null
                    : () => Navigator.pop(context, _tempFilter),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tc.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // 🔧 round 줄임
                  ),
                ),
                child: _isLoadingStats
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _tempFilter.hasFilter
                            ? '필터 적용 (${_currentStats.totalCount}개)'
                            : '전체 보기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontProv.fontFamily.isEmpty
                              ? null
                              : fontProv.fontFamily,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔧 빠른 기간 선택 섹션
  Widget _buildQuickPeriodSection(ThemeColors tc, FontProvider fontProv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: 20, color: tc.textSecondary),
            SizedBox(width: 8),
            Text(
              '빠른 기간 선택',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: tc.textPrimary,
                fontFamily: fontProv.fontFamily.isEmpty
                    ? null
                    : fontProv.fontFamily,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickPeriodButton('이번 주', 'thisWeek', tc, fontProv),
            _buildQuickPeriodButton('이번 달', 'thisMonth', tc, fontProv),
            _buildQuickPeriodButton('최근 6개월', 'recent6Months', tc, fontProv),
            _buildQuickPeriodButton('올해', 'thisYear', tc, fontProv),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickPeriodButton(
    String label,
    String value,
    ThemeColors tc,
    FontProvider fontProv,
  ) {
    final isSelected = _tempFilter.quickPeriod == value;

    return GestureDetector(
      onTap: () {
        if (isSelected) {
          _updateFilter(_tempFilter.copyWith(clearQuickPeriod: true));
        } else {
          _updateFilter(
            _tempFilter.copyWith(
              quickPeriod: value,
              clearYear: true,
              clearMonth: true,
              clearDates: true,
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? tc.primary : tc.surface,
          borderRadius: BorderRadius.circular(12), // 🔧 round 줄임
          border: Border.all(
            color: isSelected ? tc.primary : tc.primary.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.white : tc.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontFamily: fontProv.fontFamily.isEmpty
                ? null
                : fontProv.fontFamily,
          ),
        ),
      ),
    );
  }

  // 🔧 년도/월 선택 섹션
  Widget _buildDateSection(ThemeColors tc, FontProvider fontProv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: tc.textSecondary),
            SizedBox(width: 8),
            Text(
              '상세 기간',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: tc.textPrimary,
                fontFamily: fontProv.fontFamily.isEmpty
                    ? null
                    : fontProv.fontFamily,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // 🔧 년도 선택 (실제 데이터 있는 것만)
        Text(
          '년도',
          style: TextStyle(
            fontSize: 14,
            color: tc.textSecondary,
            fontFamily: fontProv.fontFamily.isEmpty
                ? null
                : fontProv.fontFamily,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildYearButton('전체', null, tc, fontProv),
            ..._availableYears.map(
              (year) => _buildYearButton('${year}년', year, tc, fontProv),
            ),
          ],
        ),

        SizedBox(height: 16),

        // 🔧 월 선택 (전체 다 표시)
        Text(
          '월',
          style: TextStyle(
            fontSize: 14,
            color: tc.textSecondary,
            fontFamily: fontProv.fontFamily.isEmpty
                ? null
                : fontProv.fontFamily,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildMonthButton('전체', null, tc, fontProv),
            ..._availableMonths.map(
              (month) => _buildMonthButton('${month}월', month, tc, fontProv),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildYearButton(
    String label,
    int? year,
    ThemeColors tc,
    FontProvider fontProv,
  ) {
    final isSelected = _tempFilter.year == year;

    return GestureDetector(
      onTap: () {
        _updateFilter(
          _tempFilter.copyWith(
            year: year,
            clearYear: year == null,
            clearQuickPeriod: true,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? tc.primary : tc.surface,
          borderRadius: BorderRadius.circular(10), // 🔧 round 줄임
          border: Border.all(
            color: isSelected ? tc.primary : tc.primary.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : tc.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontFamily: fontProv.fontFamily.isEmpty
                ? null
                : fontProv.fontFamily,
          ),
        ),
      ),
    );
  }

  Widget _buildMonthButton(
    String label,
    int? month,
    ThemeColors tc,
    FontProvider fontProv,
  ) {
    final isSelected = _tempFilter.month == month;

    return GestureDetector(
      onTap: () {
        _updateFilter(
          _tempFilter.copyWith(
            month: month,
            clearMonth: month == null,
            clearQuickPeriod: true,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? tc.primary : tc.surface,
          borderRadius: BorderRadius.circular(10), // 🔧 round 줄임
          border: Border.all(
            color: isSelected ? tc.primary : tc.primary.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : tc.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontFamily: fontProv.fontFamily.isEmpty
                ? null
                : fontProv.fontFamily,
          ),
        ),
      ),
    );
  }

  /// 🔧 날씨 필터 섹션 (기존 4개만)
  Widget _buildWeatherFilterSection(ThemeColors tc, FontProvider fontProv) {
    final weatherOptions = [
      _FilterOption(
        value: 'sunny',
        label: '맑음',
        count: _currentStats.weatherCounts['sunny'] ?? 0,
        isSelected: _tempFilter.weather == 'sunny',
        isEnabled: (_currentStats.weatherCounts['sunny'] ?? 0) > 0,
        color: Colors.orange,
      ),
      _FilterOption(
        value: 'cloudy',
        label: '흐림',
        count: _currentStats.weatherCounts['cloudy'] ?? 0,
        isSelected: _tempFilter.weather == 'cloudy',
        isEnabled: (_currentStats.weatherCounts['cloudy'] ?? 0) > 0,
        color: Colors.grey,
      ),
      _FilterOption(
        value: 'rainy',
        label: '비',
        count: _currentStats.weatherCounts['rainy'] ?? 0,
        isSelected: _tempFilter.weather == 'rainy',
        isEnabled: (_currentStats.weatherCounts['rainy'] ?? 0) > 0,
        color: Colors.blue,
      ),
      _FilterOption(
        value: 'snowy',
        label: '눈',
        count: _currentStats.weatherCounts['snowy'] ?? 0,
        isSelected: _tempFilter.weather == 'snowy',
        isEnabled: (_currentStats.weatherCounts['snowy'] ?? 0) > 0,
        color: Colors.lightBlue,
      ),
    ];

    return _buildFilterSection(
      '날씨',
      Icons.wb_sunny,
      weatherOptions,
      (value) => _updateFilter(
        _tempFilter.copyWith(
          weather: _tempFilter.weather == value ? null : value,
          clearWeather: _tempFilter.weather == value,
        ),
      ),
      tc,
      fontProv,
    );
  }

  /// 🔧 필터 섹션 (실시간 count 표시)
  Widget _buildFilterSection(
    String title,
    IconData icon,
    List<_FilterOption> options,
    Function(String) onTap,
    ThemeColors tc,
    FontProvider fontProv,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: tc.textSecondary),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: tc.textPrimary,
                fontFamily: fontProv.fontFamily.isEmpty
                    ? null
                    : fontProv.fontFamily,
              ),
            ),
            if (_isLoadingStats) ...[
              SizedBox(width: 8),
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(tc.textSecondary),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            return GestureDetector(
              onTap: option.isEnabled ? () => onTap(option.value) : null,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: option.isSelected
                      ? option.color
                      : option.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12), // 🔧 round 줄임
                  border: Border.all(
                    color: option.isSelected
                        ? option.color
                        : option.color.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${option.label} (${option.count})', // 🔧 실시간 count 표시
                  style: TextStyle(
                    fontSize: 12,
                    color: option.isSelected
                        ? Colors.white
                        : (option.isEnabled
                              ? tc.textPrimary
                              : tc.textSecondary),
                    fontWeight: option.isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontFamily: fontProv.fontFamily.isEmpty
                        ? null
                        : fontProv.fontFamily,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// 🔧 향상된 _FilterOption (count 포함)
class _FilterOption {
  final String value;
  final String label;
  final int count; // 🔧 실시간 count 추가
  final bool isSelected;
  final bool isEnabled;
  final Color color;

  const _FilterOption({
    required this.value,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.isEnabled,
    required this.color,
  });
}

// 🔧 DiaryListScreen에서 사용할 함수 (바텀시트 → 전체화면 변경)
Future<DiaryFilter?> showFilterScreen(
  BuildContext context,
  DiaryFilter currentFilter,
  Map<String, int> emotionStats,
) async {
  return await Navigator.push<DiaryFilter>(
    context,
    MaterialPageRoute(
      builder: (_) => FilterScreen(
        currentFilter: currentFilter,
        emotionStats: emotionStats,
      ),
    ),
  );
}
