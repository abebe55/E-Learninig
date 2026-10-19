import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';
import '../services/learnflow_store.dart';
import '../widgets/course_art.dart';
import 'video_player_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key, required this.course});
  final CourseModel course;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: LearnFlowStore.instance,
        builder: (context, _) {
          final store = LearnFlowStore.instance;
          final lessons = store.lessonsFor(course);
          final progress = store.progressFor(course);
          return Scaffold(
            body: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 222,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CourseArt(course: course, height: 222, width: double.infinity, radius: 0),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withOpacity(.28), Colors.transparent],
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: Row(
                              children: [
                                _RoundOverlayButton(
                                  icon: Icons.arrow_back_rounded,
                                  onTap: () => Navigator.of(context).maybePop(),
                                ),
                                const Spacer(),
                                _RoundOverlayButton(
                                  icon: Icons.favorite_border_rounded,
                                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Added to your learning list.')),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                      const SizedBox(height: 9),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFF4A340), size: 18),
                          Text('${course.rating.toStringAsFixed(1)} (124 reviews)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          _tag(course.category),
                          _tag('Beginner'),
                        ],
                      ),
                      const SizedBox(height: 13),
                      Text(course.description, style: const TextStyle(color: AppTheme.muted, height: 1.55, fontSize: 13)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.menu_book_outlined, size: 17, color: AppTheme.muted),
                          const SizedBox(width: 5),
                          Text('${course.chapters.length} Chapters', style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                          const SizedBox(width: 14),
                          const Icon(Icons.play_circle_outline_rounded, size: 17, color: AppTheme.muted),
                          const SizedBox(width: 5),
                          Text('${course.totalLessons} Lessons', style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                          const Spacer(),
                          Text('${(progress * 100).round()}%', style: const TextStyle(fontSize: 11, color: AppTheme.blue, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 5, color: AppTheme.blue, backgroundColor: AppTheme.paleBlue)),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: lessons.isEmpty ? null : () => _play(context, lessons, _firstUncompleted(store, lessons)),
                          child: Text(progress > 0 ? 'Continue Learning' : 'Start Learning'),
                        ),
                      ),
                      const SizedBox(height: 21),
                      Row(
                        children: [
                          const Expanded(child: Text('Chapters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.ink))),
                          TextButton(onPressed: () {}, child: const Text('View all')),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ...course.chapters.asMap().entries.map((entry) {
                        final chapterIndex = entry.key;
                        final chapter = entry.value;
                        final complete = chapter.lessons.where((lesson) => store.completedLessonIds.contains(lesson.id)).length;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ExpansionTile(
                            initiallyExpanded: chapterIndex == 0,
                            tilePadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 3),
                            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                            leading: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: complete == chapter.lessons.length && complete > 0 ? const Color(0xFFE1F6EE) : AppTheme.paleBlue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                complete == chapter.lessons.length && complete > 0 ? Icons.check_rounded : Icons.menu_book_outlined,
                                color: complete == chapter.lessons.length && complete > 0 ? AppTheme.green : AppTheme.blue,
                                size: 18,
                              ),
                            ),
                            title: Text('Chapter ${chapterIndex + 1}: ${chapter.title}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                            subtitle: Text('$complete/${chapter.lessons.length} lessons completed', style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                            children: chapter.lessons.map((lesson) {
                              final lessonIndex = lessons.indexWhere((item) => item.id == lesson.id);
                              final isComplete = store.completedLessonIds.contains(lesson.id);
                              final isDownloaded = store.isDownloaded(lesson.id);
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  isComplete ? Icons.check_circle_rounded : (isDownloaded ? Icons.download_done_rounded : Icons.play_circle_outline_rounded),
                                  color: isComplete ? AppTheme.green : AppTheme.blue,
                                ),
                                title: Text(lesson.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                subtitle: Text('${lesson.duration} • Video${isDownloaded ? ' • Available offline' : ''}', style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                                trailing: IconButton(
                                  tooltip: isDownloaded ? 'Downloaded' : 'Download lesson',
                                  onPressed: isDownloaded || store.downloadingIds.contains(lesson.id)
                                      ? null
                                      : () async {
                                          try {
                                            await store.downloadLesson(lesson);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('${lesson.title} saved for offline viewing.'),
                                                  backgroundColor: const Color(0xFF2CA789),
                                                ),
                                              );
                                            }
                                          } catch (error) {
                                            if (context.mounted) {
                                              String message = 'Download failed. Check your connection.';
                                              final errStr = error.toString();
                                              if (errStr.contains('403') || errStr.contains('401')) {
                                                message = 'Download failed: video server rejected the request.';
                                              } else if (errStr.contains('SocketException')) {
                                                message = 'No internet. Connect and try again.';
                                              }
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(message), backgroundColor: const Color(0xFFE14D5A)),
                                              );
                                            }
                                          }
                                        },
                                  icon: Icon(isDownloaded ? Icons.download_done_rounded : Icons.download_outlined, color: isDownloaded ? AppTheme.green : AppTheme.muted, size: 20),
                                ),
                                onTap: () => _play(context, lessons, lessonIndex),
                              );
                            }).toList(),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );

  int _firstUncompleted(LearnFlowStore store, List<LessonModel> lessons) {
    final index = lessons.indexWhere((lesson) => !store.completedLessonIds.contains(lesson.id));
    return index < 0 ? 0 : index;
  }

  void _play(BuildContext context, List<LessonModel> lessons, int index) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => VideoPlayerScreen(course: course, lessons: lessons, initialIndex: index < 0 ? 0 : index)),
      );

  Widget _tag(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(color: AppTheme.paleBlue, borderRadius: BorderRadius.circular(8)),
        child: Text(text, style: const TextStyle(color: AppTheme.blue, fontSize: 10, fontWeight: FontWeight.w700)),
      );
}

class _RoundOverlayButton extends StatelessWidget {
  const _RoundOverlayButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white.withOpacity(.92),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(width: 40, height: 40, child: Icon(icon, size: 21, color: AppTheme.ink)),
        ),
      );
}
