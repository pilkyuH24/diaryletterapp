import 'package:diaryletter/const/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diaryletter/providers/theme_provider.dart';
import 'package:diaryletter/widgets/diary/screen/home_screen/components/main_calendar.dart';
import 'package:diaryletter/widgets/diary/screen/home_screen/components/diary_card.dart';
import 'package:diaryletter/widgets/diary/screen/home_screen/components/today_banner.dart';
import 'package:diaryletter/widgets/diary/screen/diary_read/diary_read_screen.dart';
import 'package:diaryletter/model/diary_model.dart';
import 'package:diaryletter/config/ad_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<bool>? todayNotifier;
  final ValueNotifier<bool>? refreshNotifier;

  const HomeScreen({Key? key, this.todayNotifier, this.refreshNotifier})
    : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  late ValueNotifier<DateTime> focusedDayNotifier;
  Map<String, Set<DateTime>> diaryDatesCache = {};

  @override
  void initState() {
    super.initState();
    focusedDayNotifier = ValueNotifier<DateTime>(DateTime.now());
    widget.todayNotifier?.addListener(_onTodayPressed);
    widget.refreshNotifier?.addListener(_onRefreshRequested);
  }

  @override
  void dispose() {
    widget.todayNotifier?.removeListener(_onTodayPressed);
    widget.refreshNotifier?.removeListener(_onRefreshRequested);
    focusedDayNotifier.dispose();
    super.dispose();
  }

  void _onTodayPressed() {
    if (widget.todayNotifier?.value == true) {
      final today = DateTime.now();
      selectedDate = DateTime.utc(today.year, today.month, today.day);
      focusedDayNotifier.value = today;
      widget.todayNotifier!.value = false;
      setState(() {});
    }
  }

  void _onRefreshRequested() {
    diaryDatesCache.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // ➊ orientation 체크
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    if (isLandscape) {
      // 가로 모드면 빈 흰 배경만
      return Scaffold(
        backgroundColor: Colors.white,
        body: const SizedBox.expand(),
      );
    }

    final themeProv = context.watch<ThemeProvider>();
    final tc = themeProv.colors;
    final dateString =
        '${selectedDate.year}'
        '${selectedDate.month.toString().padLeft(2, '0')}'
        '${selectedDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: tc.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. 캘린더
            ValueListenableBuilder<DateTime>(
              valueListenable: focusedDayNotifier,
              builder: (context, focusedDay, _) {
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _getDiaryDatesForMonth(focusedDay),
                  builder: (context, snap) {
                    final datesWithDiary = <DateTime>{};
                    if (snap.hasData) {
                      datesWithDiary.addAll(
                        snap.data!.map((e) {
                          final ds = e['date'] as String;
                          return DateTime(
                            int.parse(ds.substring(0, 4)),
                            int.parse(ds.substring(4, 6)),
                            int.parse(ds.substring(6, 8)),
                          );
                        }),
                      );
                    }
                    return Container(
                      padding: const EdgeInsets.only(bottom: 12),
                      color: tc.background,
                      child: MainCalendar(
                        selectedDate: selectedDate,
                        focusedDay: focusedDay,
                        onDaySelected: onDaySelected,
                        onPageChanged: onPageChanged,
                        datesWithDiary: datesWithDiary,
                      ),
                    );
                  },
                );
              },
            ),

            // 2. 오늘 배너
            FutureBuilder<List<Map<String, dynamic>>>(
              future: Supabase.instance.client
                  .from('diary')
                  .select()
                  .eq('date', dateString)
                  .then((data) => (data as List).cast<Map<String, dynamic>>()),
              builder: (context, snap) {
                return TodayBanner(
                  selectedDate: selectedDate,
                  count: snap.data?.length ?? 0,
                  onTodayPressed: () => widget.todayNotifier?.value = true,
                );
              },
            ),

            // 3. 일기 목록
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: Supabase.instance.client
                    .from('diary')
                    .select()
                    .eq('date', dateString)
                    .then(
                      (data) => (data as List).cast<Map<String, dynamic>>(),
                    ),
                builder: (context, snap) {
                  if (snap.hasError) return _buildError(tc);
                  if (snap.connectionState == ConnectionState.waiting ||
                      !snap.hasData) {
                    return Center(
                      child: CircularProgressIndicator(color: tc.primary),
                    );
                  }
                  final diaries = snap.data!
                      .map((e) => DiaryModel.fromJson(json: e))
                      .toList();
                  return _buildDiaryList(diaries, tc);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(ThemeColors tc) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 48, color: tc.secondary),
        const SizedBox(height: 16),
        Text('일기를 불러오지 못했습니다', style: TextStyle(color: tc.secondary)),
      ],
    ),
  );

  Widget _buildDiaryList(List<DiaryModel> diaries, ThemeColors tc) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [tc.primary, tc.surface, tc.surface],
        ),
      ),
      child: diaries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: tc.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    '이 날의 일기가 없습니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: tc.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(
                8,
                12,
                8,
                AdConfig.contentBottomPadding,
              ),
              itemCount: diaries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final d = diaries[i];
                return DiaryCard(
                  title: d.title,
                  content: d.content,
                  createdAt: d.createdAt,
                  emotion: d.emotion,
                  weather: d.weather,
                  socialContext: d.socialContext,
                  activityType: d.activityType,
                  onTap: () => _readDiary(d),
                );
              },
            ),
    );
  }

  Future<List<Map<String, dynamic>>> _getDiaryDatesForMonth(
    DateTime focusedDay,
  ) async {
    final monthKey = '${focusedDay.year}-${focusedDay.month}';
    if (diaryDatesCache.containsKey(monthKey)) {
      return diaryDatesCache[monthKey]!.map((date) {
        final ds =
            '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
        return {'date': ds};
      }).toList();
    }
    try {
      final data = await Supabase.instance.client
          .from('diary')
          .select('date')
          .gte(
            'date',
            '${focusedDay.year}${focusedDay.month.toString().padLeft(2, '0')}01',
          )
          .lt(
            'date',
            '${focusedDay.year}${(focusedDay.month + 1).toString().padLeft(2, '0')}01',
          );
      final list = (data as List).cast<Map<String, dynamic>>();
      final set = list.map((e) {
        final ds = e['date'] as String;
        return DateTime(
          int.parse(ds.substring(0, 4)),
          int.parse(ds.substring(4, 6)),
          int.parse(ds.substring(6, 8)),
        );
      }).toSet();
      diaryDatesCache[monthKey] = set;
      return list;
    } catch (_) {
      return [];
    }
  }

  void onDaySelected(DateTime sel, DateTime foc) {
    selectedDate = sel;
    setState(() {});
  }

  void onPageChanged(DateTime foc) {
    focusedDayNotifier.value = foc;
  }

  Future<void> _readDiary(DiaryModel diary) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => DiaryReadScreen(diary: diary)),
    );
    if (result?['refresh'] == true) {
      diaryDatesCache.clear();
      setState(() {});
      widget.refreshNotifier?.value = !widget.refreshNotifier!.value;
    }
  }
}
