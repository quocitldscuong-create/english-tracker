import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/lesson.dart';
import '../services/storage_service.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with SingleTickerProviderStateMixin {
  late bool _isCompleted;
  bool _copied = false;
  late AnimationController _checkController;
  late Animation<double> _checkScale;

  static const Color _accent = Color(0xFF00E5FF);
  static const Color _green = Color(0xFF00FF88);
  static const Color _bg = Color(0xFF121212);
  static const Color _card = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.lesson.isCompleted;
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
    if (_isCompleted) _checkController.value = 1.0;
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  Future<void> _toggleCompletion() async {
    final newValue = !_isCompleted;
    await StorageService.setLessonCompleted(widget.lesson.dayIndex, newValue);
    setState(() => _isCompleted = newValue);
    if (newValue) {
      _checkController.forward(from: 0);
      HapticFeedback.mediumImpact();
    } else {
      _checkController.reverse();
    }
  }

  Future<void> _openVideo() async {
    if (widget.lesson.videoUrl == null) return;
    final uri = Uri.parse(widget.lesson.videoUrl!);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open video')),
        );
      }
    }
  }

  Future<void> _copyPrompt() async {
    await Clipboard.setData(ClipboardData(text: widget.lesson.promptText));
    setState(() => _copied = true);
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (widget.lesson.hasVideo) ...[
                  _buildSectionLabel('📺  VIDEO', _accent),
                  const SizedBox(height: 10),
                  _buildVideoCard(),
                  const SizedBox(height: 24),
                ],
                _buildSectionLabel('📖  READING', _accent),
                const SizedBox(height: 10),
                _buildReadingCard(),
                const SizedBox(height: 24),
                _buildSectionLabel('🤖  AI PROMPT', _accent),
                const SizedBox(height: 10),
                _buildPromptCard(),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: _bg,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white70, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.lesson.dayName.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _accent,
              letterSpacing: 2.5,
            ),
          ),
          const Text(
            'Daily Lesson',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        if (_isCompleted)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ScaleTransition(
              scale: _checkScale,
              child: const Icon(Icons.verified_rounded,
                  color: _green, size: 26),
            ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.white.withOpacity(0.06),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: color.withOpacity(0.7),
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildVideoCard() {
    return GestureDetector(
      onTap: _openVideo,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: _card,
          border:
              Border.all(color: _accent.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            // Thumbnail placeholder with play icon
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0A1628),
                          const Color(0xFF0D1F3C),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _accent.withOpacity(0.15),
                            border: Border.all(
                                color: _accent.withOpacity(0.5), width: 2),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: _accent,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'TAP TO WATCH ON YOUTUBE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _accent.withOpacity(0.6),
                            letterSpacing: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.smart_display_rounded,
                      color: Color(0xFFFF4444), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.lesson.videoTitle ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const Icon(Icons.open_in_new_rounded,
                      color: Colors.white30, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: _card,
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _accent.withOpacity(0.08),
            ),
            child: const Icon(Icons.article_rounded,
                color: _accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reading Task',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.lesson.readingTask,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse('https://medium.com');
                    if (!await launchUrl(uri,
                        mode: LaunchMode.externalApplication)) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Could not open Medium')),
                        );
                      }
                    }
                  },
                  child: Text(
                    'Open Medium →',
                    style: TextStyle(
                      fontSize: 13,
                      color: _accent.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: _accent.withOpacity(0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: _card,
        border: Border.all(
          color: const Color(0xFF00FF88).withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF88).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              color: const Color(0xFF00FF88).withOpacity(0.07),
              border: Border(
                bottom: BorderSide(
                    color: const Color(0xFF00FF88).withOpacity(0.15)),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology_rounded,
                    color: _green, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'AI Prompt — Copy & Paste into ChatGPT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _green,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Prompt text
          Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              widget.lesson.promptText,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.7,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          // Copy button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              child: ElevatedButton.icon(
                onPressed: _copyPrompt,
                icon: Icon(
                  _copied ? Icons.check_rounded : Icons.copy_rounded,
                  size: 18,
                ),
                label: Text(_copied ? 'Copied!' : 'Copy to Clipboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _copied ? _green : _green.withOpacity(0.15),
                  foregroundColor: _copied ? Colors.black : _green,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: _green.withOpacity(_copied ? 0 : 0.5),
                    ),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        border:
            Border(top: BorderSide(color: Colors.white.withOpacity(0.07))),
      ),
      child: GestureDetector(
        onTap: _toggleCompletion,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: _isCompleted
                ? LinearGradient(
                    colors: [
                      _green.withOpacity(0.9),
                      const Color(0xFF00CC66),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      _accent.withOpacity(0.2),
                      _accent.withOpacity(0.08),
                    ],
                  ),
            border: Border.all(
              color: _isCompleted
                  ? _green.withOpacity(0.8)
                  : _accent.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: _isCompleted ? Colors.black : _accent,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                _isCompleted ? 'Completed! Tap to Undo' : 'Mark as Completed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _isCompleted ? Colors.black : _accent,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
