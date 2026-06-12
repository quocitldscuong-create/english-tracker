import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../data/schedule_data.dart';
import '../services/storage_service.dart';
import '../widgets/day_card.dart';
import 'lesson_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Lesson> _lessons = [];
  bool _loading = true;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final lessons = ScheduleData.getLessons();
    final statusMap = await StorageService.getAllCompletionStatus();
    for (final lesson in lessons) {
      lesson.isCompleted = statusMap[lesson.dayIndex] ?? false;
    }
    if (mounted) {
      setState(() {
        _lessons = lessons;
        _loading = false;
      });
      _animController.forward(from: 0);
    }
  }

  int get _todayIndex {
    final weekday = DateTime.now().weekday; // 1=Mon .. 7=Sun
    if (weekday >= 1 && weekday <= 5) return weekday - 1;
    return -1;
  }

  int get _completedCount => _lessons.where((l) => l.isCompleted).length;

  double get _progressPercent =>
      _lessons.isEmpty ? 0 : _completedCount / _lessons.length;

  Future<void> _openLesson(Lesson lesson) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: LessonScreen(lesson: lesson),
        ),
      ),
    );
    // Refresh after returning
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(child: _buildProgressHeader()),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final lesson = _lessons[index];
                      final delay = index * 80;
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration:
                            Duration(milliseconds: 400 + delay),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) => Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        ),
                        child: DayCard(
                          lesson: lesson,
                          isToday: lesson.dayIndex == _todayIndex,
                          onTap: () => _openLesson(lesson),
                        ),
                      );
                    },
                    childCount: _lessons.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF121212),
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding:
            const EdgeInsets.only(left: 20, bottom: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ENGLISH TRACKER',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00E5FF),
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Weekly Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white54),
          tooltip: 'Reset progress',
          onPressed: _confirmReset,
        ),
      ],
    );
  }

  Widget _buildProgressHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF00E5FF).withOpacity(0.08),
              const Color(0xFF00FF88).withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: const Color(0xFF00E5FF).withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weekly Progress',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white60,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '$_completedCount / ${_lessons.length} days',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00E5FF),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _progressPercent),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          value >= 1.0
                              ? const Color(0xFF00FF88)
                              : const Color(0xFF00E5FF),
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value >= 1.0
                          ? '🎉 Week complete! Great job!'
                          : value == 0
                              ? 'Start your first lesson →'
                              : '${(value * 100).toStringAsFixed(0)}% complete — keep going!',
                      style: TextStyle(
                        fontSize: 12,
                        color: value >= 1.0
                            ? const Color(0xFF00FF88)
                            : Colors.white38,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Progress',
            style: TextStyle(color: Colors.white, fontSize: 17)),
        content: const Text(
          'This will clear all completed days. Are you sure?',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await StorageService.resetAllProgress();
              await _loadData();
            },
            child: const Text('Reset',
                style: TextStyle(color: Color(0xFFFF4444))),
          ),
        ],
      ),
    );
  }
}
