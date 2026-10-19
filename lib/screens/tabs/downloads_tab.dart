import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../models/lesson_model.dart';
import '../../services/learnflow_store.dart';
import '../video_player_screen.dart';

/// Downloads screen with two tabs: active downloads and completed downloads.
/// Also shows a storage usage indicator.
class DownloadsTab extends StatefulWidget {
  const DownloadsTab({super.key});

  @override
  State<DownloadsTab> createState() => _DownloadsTabState();
}

class _DownloadsTabState extends State<DownloadsTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Estimated file size per video (used for display purposes only).
  static const _estimatedMbPerVideo = 18;
  static const _storageLimitMb = 10240; // 10 GB display ceiling

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LearnFlowStore.instance,
      builder: (context, _) {
        final store = LearnFlowStore.instance;
        final completed = store.downloadedPaths.keys
            .map(store.lessonById)
            .whereType<LessonModel>()
            .toList();
        final activeIds = store.downloadingIds.toList();
        final usedMb = completed.length * _estimatedMbPerVideo;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Downloads',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        _showStorageInfo(context, usedMb, _storageLimitMb),
                    icon: const Icon(Icons.storage_outlined),
                    tooltip: 'Storage info',
                  ),
                  if (completed.isNotEmpty)
                    IconButton(
                      onPressed: () => _confirmClearAll(context, store),
                      icon: const Icon(Icons.delete_outline_rounded),
                      tooltip: 'Clear all downloads',
                    ),
                ],
              ),
            ),
            // Tab bar
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: TabBar(
                controller: _tabController,
                dividerColor: AppTheme.line,
                indicatorColor: AppTheme.blue,
                labelColor: AppTheme.blue,
                unselectedLabelColor: AppTheme.muted,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
                tabs: [
                  Tab(text: 'Downloading (${activeIds.length})'),
                  Tab(text: 'Completed (${completed.length})'),
                ],
              ),
            ),
            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ActiveDownloadsView(activeIds: activeIds, store: store),
                  _CompletedDownloadsView(
                    lessons: completed,
                    store: store,
                    usedMb: usedMb,
                    storageLimitMb: _storageLimitMb,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showStorageInfo(
      BuildContext context, int usedMb, int limitMb) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Storage Info'),
        content: Text(
          'Using ~$usedMb MB of estimated ${limitMb ~/ 1024} GB app storage.\n\n'
          'Downloaded videos are stored in private app storage and can be '
          'removed individually from the Completed tab.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, LearnFlowStore store) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all downloads?'),
        content: const Text(
          'This removes all downloaded videos from this device. '
          'You can re-download them any time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ids = store.downloadedPaths.keys.toList();
              for (final id in ids) {
                await store.removeDownload(id);
              }
            },
            child: const Text(
              'Clear all',
              style: TextStyle(color: Color(0xFFE14D5A)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Active downloads ─────────────────────────────────────────────────────────

class _ActiveDownloadsView extends StatelessWidget {
  const _ActiveDownloadsView({
    required this.activeIds,
    required this.store,
  });

  final List<String> activeIds;
  final LearnFlowStore store;

  @override
  Widget build(BuildContext context) {
    if (activeIds.isEmpty) {
      return const _EmptyState(
        icon: Icons.downloading_rounded,
        title: 'Nothing downloading',
        subtitle: 'Start a download from any course page.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      itemCount: activeIds.length,
      itemBuilder: (context, i) {
        final id = activeIds[i];
        final lesson = store.lessonById(id);
        if (lesson == null) return const SizedBox.shrink();
        final progress = store.downloadProgress[id] ?? 0;
        final downloadedMb = (progress * 18).toStringAsFixed(1);

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.paleBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.video_file_outlined,
                    color: AppTheme.blue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$downloadedMb MB / 18 MB',
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 7),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          color: AppTheme.blue,
                          backgroundColor: AppTheme.paleBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          color: AppTheme.blue,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Completed downloads ───────────────────────────────────────────────────────

class _CompletedDownloadsView extends StatelessWidget {
  const _CompletedDownloadsView({
    required this.lessons,
    required this.store,
    required this.usedMb,
    required this.storageLimitMb,
  });

  final List<LessonModel> lessons;
  final LearnFlowStore store;
  final int usedMb;
  final int storageLimitMb;

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return const _EmptyState(
        icon: Icons.download_for_offline_outlined,
        title: 'No downloads yet',
        subtitle: 'Your saved lessons will appear here.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      children: [
        ...lessons.map((lesson) {
          final course = store.courseForLesson(lesson.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Card(
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F6EE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppTheme.green,
                    size: 22,
                  ),
                ),
                title: Text(
                  lesson.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  '${course?.title ?? 'Course video'} • 18 MB',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'remove') {
                      await store.removeDownload(lesson.id);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'remove',
                      child: Text('Remove download'),
                    ),
                  ],
                ),
                onTap: course == null
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VideoPlayerScreen(
                              course: course,
                              lessons: store.lessonsFor(course),
                              initialIndex: store
                                  .lessonsFor(course)
                                  .indexWhere((l) => l.id == lesson.id),
                            ),
                          ),
                        ),
              ),
            ),
          );
        }),
        const SizedBox(height: 10),
        // Storage bar
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.storage_outlined,
                      size: 16, color: AppTheme.muted),
                  const SizedBox(width: 6),
                  const Text(
                    'Storage Used',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$usedMb MB / ${storageLimitMb ~/ 1024} GB',
                    style: const TextStyle(
                      color: AppTheme.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: usedMb / storageLimitMb,
                  minHeight: 6,
                  color: AppTheme.blue,
                  backgroundColor: AppTheme.paleBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Shared empty state ────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: AppTheme.blue),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
