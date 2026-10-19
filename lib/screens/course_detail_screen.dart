import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../models/chapter_model.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';
import '../services/learnflow_store.dart';
import '../widgets/course_art.dart';
import 'video_player_screen.dart';

/// Displays all chapters and lessons for a course, with progress, download
/// controls, and a start/continue button.
class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key, required this.course});

  final CourseModel course;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LearnFlowStore.instance,
      builder: (context, _) {
        final store = LearnFlowStore.instance;
        final lessons = store.lessonsFor(course);
        final progress = store.progressFor(course);

        return Scaffold(
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              _HeroHeader(course: course),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 9),
                    // Rating + tags
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF4A340),
                          size: 18,
                        ),
                        Text(
                          '${course.rating.toStringAsFixed(1)} (124 reviews)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _Tag(course.category),
                        const _Tag('Beginner'),
                      ],
                    ),
                    const SizedBox(height: 13),
                    // Description
                    Text(
                      course.description,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        height: 1.55,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Chapter / lesson counts + progress %
                    Row(
                      children: [
                        const Icon(
                          Icons.menu_book_outlined,
                          size: 17,
                          color: AppTheme.muted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${course.chapters.length} Chapters',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.muted,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Icon(
                          Icons.play_circle_outline_rounded,
                          size: 17,
                          color: AppTheme.muted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${course.totalLessons} Lessons',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.muted,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(progress * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.blue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        color: AppTheme.blue,
                        backgroundColor: AppTheme.paleBlue,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Start / continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: lessons.isEmpty
                            ? null
                            : () => _playLesson(
                                  context,
                                  lessons,
                                  _firstUncompletedIndex(store, lessons),
                                ),
                        child: Text(
                          progress > 0 ? 'Continue Learning' : 'Start Learning',
                        ),
                      ),
                    ),
                    const SizedBox(height: 21),
                    // Chapters header
                    const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Chapters',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Chapter tiles
                    ...course.chapters.asMap().entries.map(
                          (entry) => _ChapterTile(
                            chapterIndex: entry.key,
                            chapter: entry.value,
                            allLessons: lessons,
                            store: store,
                            onLessonTap: (index) =>
                                _playLesson(context, lessons, index),
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Returns the index of the first lesson the user has not completed,
  /// defaulting to 0 if all are done.
  int _firstUncompletedIndex(LearnFlowStore store, List<LessonModel> lessons) {
    final index = lessons
        .indexWhere((l) => !store.completedLessonIds.contains(l.id));
    return index < 0 ? 0 : index;
  }

  void _playLesson(
    BuildContext context,
    List<LessonModel> lessons,
    int index,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          course: course,
          lessons: lessons,
          initialIndex: index < 0 ? 0 : index,
        ),
      ),
    );
  }
}

// ── Hero header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.course});

  final CourseModel course;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 222,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CourseArt(
            course: course,
            height: 222,
            width: double.infinity,
            radius: 0,
          ),
          // Gradient overlay
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(.28),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Back + favourite buttons
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    _RoundButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const Spacer(),
                    _RoundButton(
                      icon: Icons.favorite_border_rounded,
                      onTap: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to your learning list.'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chapter expansion tile ────────────────────────────────────────────────────

class _ChapterTile extends StatelessWidget {
  const _ChapterTile({
    required this.chapterIndex,
    required this.chapter,
    required this.allLessons,
    required this.store,
    required this.onLessonTap,
  });

  final int chapterIndex;
  final ChapterModel chapter;
  final List<LessonModel> allLessons;
  final LearnFlowStore store;
  final void Function(int lessonIndex) onLessonTap;

  @override
  Widget build(BuildContext context) {
    final completedCount = chapter.lessons
        .where((l) => store.completedLessonIds.contains(l.id))
        .length;
    final isChapterDone =
        completedCount == chapter.lessons.length && completedCount > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        initiallyExpanded: chapterIndex == 0,
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 13, vertical: 3),
        childrenPadding:
            const EdgeInsets.fromLTRB(12, 0, 12, 10),
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isChapterDone
                ? const Color(0xFFE1F6EE)
                : AppTheme.paleBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isChapterDone
                ? Icons.check_rounded
                : Icons.menu_book_outlined,
            color: isChapterDone ? AppTheme.green : AppTheme.blue,
            size: 18,
          ),
        ),
        title: Text(
          'Chapter ${chapterIndex + 1}: ${chapter.title}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          '$completedCount/${chapter.lessons.length} lessons completed',
          style: const TextStyle(fontSize: 11, color: AppTheme.muted),
        ),
        children: chapter.lessons
            .map(
              (lesson) => _LessonTile(
                lesson: lesson,
                lessonIndex: allLessons.indexWhere((l) => l.id == lesson.id),
                store: store,
                onTap: onLessonTap,
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Lesson list tile ──────────────────────────────────────────────────────────

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.lesson,
    required this.lessonIndex,
    required this.store,
    required this.onTap,
  });

  final LessonModel lesson;
  final int lessonIndex;
  final LearnFlowStore store;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final isComplete = store.completedLessonIds.contains(lesson.id);
    final isDownloaded = store.isDownloaded(lesson.id);
    final isDownloading = store.downloadingIds.contains(lesson.id);

    IconData leadingIcon;
    Color leadingColor;
    if (isComplete) {
      leadingIcon = Icons.check_circle_rounded;
      leadingColor = AppTheme.green;
    } else if (isDownloaded) {
      leadingIcon = Icons.download_done_rounded;
      leadingColor = AppTheme.blue;
    } else {
      leadingIcon = Icons.play_circle_outline_rounded;
      leadingColor = AppTheme.blue;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(leadingIcon, color: leadingColor),
      title: Text(
        lesson.title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        '${lesson.duration} • Video'
        '${isDownloaded ? ' • Available offline' : ''}',
        style: const TextStyle(fontSize: 11, color: AppTheme.muted),
      ),
      trailing: isDownloading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              tooltip:
                  isDownloaded ? 'Downloaded' : 'Download for offline',
              onPressed: isDownloaded
                  ? null
                  : () => _download(context),
              icon: Icon(
                isDownloaded
                    ? Icons.download_done_rounded
                    : Icons.download_outlined,
                color: isDownloaded ? AppTheme.green : AppTheme.muted,
                size: 20,
              ),
            ),
      onTap: () => onTap(lessonIndex),
    );
  }

  Future<void> _download(BuildContext context) async {
    try {
      await store.downloadLesson(lesson);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${lesson.title} saved for offline viewing.'),
            backgroundColor: AppTheme.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final msg = e.toString().contains('SocketException')
            ? 'No internet. Connect and try again.'
            : 'Download failed. Check your connection.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: const Color(0xFFE14D5A),
          ),
        );
      }
    }
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  const _Tag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.paleBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.blue,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 21, color: AppTheme.ink),
        ),
      ),
    );
  }
}
