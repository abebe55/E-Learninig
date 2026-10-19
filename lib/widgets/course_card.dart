import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../models/course_model.dart';
import '../services/learnflow_store.dart';
import 'course_art.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.course, required this.onTap, this.compact = false});
  final CourseModel course;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final store = LearnFlowStore.instance;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: compact
              ? Row(children: [
                  CourseArt(course: course, height: 68, width: 76),
                  const SizedBox(width: 12),
                  Expanded(child: _CourseCopy(course: course, compact: true)),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
                ])
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CourseArt(course: course, height: 120, width: double.infinity),
                  const SizedBox(height: 10),
                  _CourseCopy(course: course),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF4A340)),
                    const SizedBox(width: 3),
                    Text(course.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 5),
                    const Expanded(child: Text('(124 reviews)', style: TextStyle(color: AppTheme.muted, fontSize: 11), overflow: TextOverflow.ellipsis)),
                    Text('${store.completedCountFor(course)}/${course.totalLessons}', style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
                  ]),
                ]),
        ),
      ),
    );
  }
}

class _CourseCopy extends StatelessWidget {
  const _CourseCopy({required this.course, this.compact = false});
  final CourseModel course;
  final bool compact;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(course.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.ink)),
        const SizedBox(height: 5),
        Text('${course.chapters.length} chapters • ${course.totalLessons} lessons', style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
        if (!compact) ...[
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: LearnFlowStore.instance.progressFor(course), minHeight: 4, backgroundColor: AppTheme.paleBlue, color: AppTheme.blue)),
        ],
      ]);
}
