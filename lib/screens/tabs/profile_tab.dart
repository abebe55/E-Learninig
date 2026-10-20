import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../services/learnflow_store.dart';
import '../auth_screen.dart';
import '../settings_screen.dart';

/// Profile tab — shows user info, learning stats, and quick actions.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, this.onDownloads});

  /// Called when the user taps "Downloads" to switch to the Downloads tab.
  final VoidCallback? onDownloads;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LearnFlowStore.instance,
      builder: (context, _) {
        final store = LearnFlowStore.instance;
        final totalLessons = store.courses
            .fold<int>(0, (sum, c) => sum + c.totalLessons);

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          children: [
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 16),
            // User card
            _UserCard(store: store),
            const SizedBox(height: 12),
            // Stats card
            _StatsCard(store: store),
            const SizedBox(height: 22),
            const Text(
              'Learning',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            _ProfileAction(
              icon: Icons.insights_outlined,
              title: 'My Learning Progress',
              onTap: () => _showProgress(context, store),
            ),
            _ProfileAction(
              icon: Icons.download_outlined,
              title: 'Downloads',
              onTap: () => onDownloads?.call(),
            ),
            _ProfileAction(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              ),
            ),
            _ProfileAction(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'LearnFlow',
                applicationVersion: '1.0.0',
                children: const [
                  Text('LearnFlow student learning app prototype.')
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Logout
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFE14D5A),
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Color(0xFFE14D5A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                onTap: () async {
                  await store.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const AuthScreen(),
                      ),
                      (_) => false,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'LearnFlow • $totalLessons lessons available',
                style: const TextStyle(color: AppTheme.muted, fontSize: 11),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showProgress(BuildContext context, LearnFlowStore store) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'My Learning Progress',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          ...store.courses.map(
            (course) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 7),
                  LinearProgressIndicator(
                    value: store.progressFor(course),
                    minHeight: 6,
                    color: AppTheme.blue,
                    backgroundColor: AppTheme.paleBlue,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${store.completedCountFor(course)} of '
                    '${course.totalLessons} lessons completed',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private widgets ──────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard({required this.store});

  final LearnFlowStore store;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.paleBlue,
              child: Text(
                store.userName.isEmpty
                    ? 'L'
                    : store.userName[0].toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.blue,
                  fontWeight: FontWeight.w800,
                  fontSize: 21,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.userEmail,
                    style: const TextStyle(
                      color: AppTheme.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _editName(context),
              icon: const Icon(Icons.edit_outlined, color: AppTheme.blue),
            ),
          ],
        ),
      ),
    );
  }

  void _editName(BuildContext context) {
    final controller = TextEditingController(text: store.userName);
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Edit profile name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.length >= 2) {
                await LearnFlowStore.instance.updateProfileName(value);
              }
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.store});

  final LearnFlowStore store;

  /// Calculates total hours spent on completed lessons from their durations.
  int _learningHours() {
    var totalMinutes = 0;
    for (final course in store.courses) {
      for (final lesson in store.lessonsFor(course)) {
        if (store.completedLessonIds.contains(lesson.id)) {
          final parts = lesson.duration.split(':');
          if (parts.length == 2) {
            totalMinutes += int.tryParse(parts[0]) ?? 0;
          }
        }
      }
    }
    return (totalMinutes / 60).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _Stat(
                value: '${store.courses.length}',
                label: 'Courses',
              ),
            ),
            Expanded(
              child: _Stat(
                value: '${store.completedLessonIds.length}',
                label: 'Completed',
              ),
            ),
            Expanded(
              child: _Stat(
                value: '${_learningHours()}h',
                label: 'Learning Time',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppTheme.muted, fontSize: 11),
        ),
      ],
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 7),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: AppTheme.blue, size: 21),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        trailing:
            const Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
        onTap: onTap,
      ),
    );
  }
}
