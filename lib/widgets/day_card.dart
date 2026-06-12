import 'package:flutter/material.dart';
import '../models/lesson.dart';

class DayCard extends StatelessWidget {
  final Lesson lesson;
  final bool isToday;
  final VoidCallback onTap;

  const DayCard({
    super.key,
    required this.lesson,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor = const Color(0xFF00E5FF);
    final Color completedColor = const Color(0xFF00FF88);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: lesson.isCompleted
              ? const Color(0xFF0D2B1A)
              : isToday
                  ? const Color(0xFF0A1A2A)
                  : const Color(0xFF1E1E1E),
          border: Border.all(
            color: lesson.isCompleted
                ? completedColor.withOpacity(0.6)
                : isToday
                    ? accentColor.withOpacity(0.6)
                    : const Color(0xFF2C2C2C),
            width: lesson.isCompleted || isToday ? 1.5 : 1,
          ),
          boxShadow: [
            if (lesson.isCompleted)
              BoxShadow(
                color: completedColor.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            if (isToday && !lesson.isCompleted)
              BoxShadow(
                color: accentColor.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              // Day indicator circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: lesson.isCompleted
                      ? completedColor.withOpacity(0.15)
                      : isToday
                          ? accentColor.withOpacity(0.12)
                          : const Color(0xFF2A2A2A),
                  border: Border.all(
                    color: lesson.isCompleted
                        ? completedColor
                        : isToday
                            ? accentColor
                            : const Color(0xFF3A3A3A),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: lesson.isCompleted
                      ? Icon(Icons.check_rounded,
                          color: completedColor, size: 22)
                      : Text(
                          lesson.dayName.substring(0, 2).toUpperCase(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isToday ? accentColor : Colors.white54,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Day info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          lesson.dayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: lesson.isCompleted
                                ? completedColor
                                : isToday
                                    ? Colors.white
                                    : Colors.white70,
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: accentColor.withOpacity(0.4)),
                            ),
                            child: Text(
                              'TODAY',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: accentColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (lesson.hasVideo) ...[
                          Icon(Icons.play_circle_outline_rounded,
                              size: 13,
                              color: lesson.isCompleted
                                  ? completedColor.withOpacity(0.6)
                                  : Colors.white38),
                          const SizedBox(width: 4),
                          Text('Video',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: lesson.isCompleted
                                      ? completedColor.withOpacity(0.7)
                                      : Colors.white38)),
                          const SizedBox(width: 12),
                        ],
                        Icon(Icons.article_outlined,
                            size: 13,
                            color: lesson.isCompleted
                                ? completedColor.withOpacity(0.6)
                                : Colors.white38),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lesson.readingTask,
                            style: TextStyle(
                                fontSize: 12,
                                color: lesson.isCompleted
                                    ? completedColor.withOpacity(0.7)
                                    : Colors.white38),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Chevron / status icon
              Icon(
                lesson.isCompleted
                    ? Icons.verified_rounded
                    : Icons.chevron_right_rounded,
                color: lesson.isCompleted ? completedColor : Colors.white24,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
