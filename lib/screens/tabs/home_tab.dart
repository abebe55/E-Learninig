import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../models/course_model.dart';
import '../../services/learnflow_store.dart';
import '../../widgets/course_art.dart';
import '../../widgets/course_card.dart';
import '../course_detail_screen.dart';

/// Home dashboard — greets the user, shows "Continue Learning" and popular
/// courses. Tapping the search bar navigates to the Explore tab via
/// [onExplore].
class HomeTab extends StatelessWidget {
  const HomeTab({super.key, this.onExplore});

  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LearnFlowStore.instance,
      builder: (context, _) {
        final store = LearnFlowStore.instance;

        // Pick the first in-progress course, falling back to the first course.
        final inProgress = store.courses
            .where((c) =>
                store.completedCountFor(c) > 0 && store.progressFor(c) < 1)
            .toList();
        final continueCourse =
            inProgress.isNotEmpty ? inProgress.first : store.courses.first;

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            _Header(store: store),
            const SizedBox(height: 18),
            _SearchBox(onTap: onExplore ?? () {}),
            const SizedBox(height: 16),
            const _BannerCard(),
            const SizedBox(height: 24),
            _SectionTitle(
              title: 'Continue Learning',
              action: 'View all',
              onTap: onExplore ?? () {},
            ),
            const SizedBox(height: 10),
            _ContinueLearningCard(
              course: continueCourse,
              store: store,
              onTap: () => _openCourse(context, continueCourse),
            ),
            const SizedBox(height: 24),
            _SectionTitle(
              title: 'Popular Courses',
              action: 'View all',
              onTap: onExplore ?? () {},
            ),
            const SizedBox(height: 10),
            ...store.courses.take(4).map(
                  (course) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: CourseCard(
                      course: course,
                      compact: true,
                      onTap: () => _openCourse(context, course),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }

  void _openCourse(BuildContext context, CourseModel course) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course)),
    );
  }
}

// ── Private widgets ──────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.store});

  final LearnFlowStore store;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good morning,',
                style: TextStyle(color: AppTheme.muted, fontSize: 13),
              ),
              const SizedBox(height: 3),
              Text(
                '${store.userName} 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.ink,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You are all caught up!')),
          ),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        CircleAvatar(
          backgroundColor: AppTheme.paleBlue,
          child: Text(
            store.userName.isEmpty ? 'L' : store.userName[0].toUpperCase(),
            style: const TextStyle(
              color: AppTheme.blue,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppTheme.line),
        ),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, color: AppTheme.ink, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search courses...',
                style: TextStyle(color: AppTheme.muted, fontSize: 13),
              ),
            ),
            Icon(Icons.tune_rounded, color: AppTheme.muted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Build Your Skills\nFor a Better Future',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Learn from expert instructors.',
                  style: TextStyle(color: AppTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Image.asset(
            'assets/images/splash_learner.png',
            height: 90,
            width: 95,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({
    required this.course,
    required this.store,
    required this.onTap,
  });

  final CourseModel course;
  final LearnFlowStore store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = store.progressFor(course);
    final completed = store.completedCountFor(course);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              CourseArt(course: course, height: 68, width: 75),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completed of ${course.totalLessons} lessons completed',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: AppTheme.paleBlue,
                        color: AppTheme.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(color: AppTheme.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.action,
    required this.onTap,
  });

  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(action, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
