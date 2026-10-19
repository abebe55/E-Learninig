import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';
import '../services/learnflow_store.dart';
import '../widgets/course_art.dart';
import '../widgets/course_card.dart';
import 'course_detail_screen.dart';
import 'settings_screen.dart';
import 'video_player_screen.dart';
import 'auth_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, this.onExplore});
  final VoidCallback? onExplore;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: LearnFlowStore.instance,
        builder: (context, _) {
          final store = LearnFlowStore.instance;
          final inProgress = store.courses.where((course) => store.completedCountFor(course) > 0 && store.progressFor(course) < 1).toList();
          final continueCourse = inProgress.isNotEmpty ? inProgress.first : store.courses.first;
          return ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 24), children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Good morning,', style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                const SizedBox(height: 3),
                Text('${store.userName} 👋', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.ink, fontSize: 21, fontWeight: FontWeight.w800)),
              ])),
              IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You are all caught up!'))), icon: const Icon(Icons.notifications_none_rounded)),
              CircleAvatar(backgroundColor: AppTheme.paleBlue, child: Text(store.userName.isEmpty ? 'L' : store.userName[0].toUpperCase(), style: const TextStyle(color: AppTheme.blue, fontWeight: FontWeight.w800))),
            ]),
            const SizedBox(height: 18),
            _SearchBox(onTap: () => onExplore?.call()),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(color: const Color(0xFFEAF3FF), borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('Build Your Skills\nFor a Better Future', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.ink, height: 1.25)),
                  SizedBox(height: 7),
                  Text('Learn from expert instructors.', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
                ])),
                const SizedBox(width: 6),
                Image.asset('assets/images/splash_learner.png', height: 90, width: 95, fit: BoxFit.contain),
              ]),
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: 'Continue Learning', action: 'View all', onTap: () => onExplore?.call()),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _openCourse(context, continueCourse),
              borderRadius: BorderRadius.circular(17),
              child: Card(child: Padding(padding: const EdgeInsets.all(10), child: Row(children: [
                CourseArt(course: continueCourse, height: 68, width: 75),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(continueCourse.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('${store.completedCountFor(continueCourse)} of ${continueCourse.totalLessons} lessons completed', style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                  const SizedBox(height: 8),
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: store.progressFor(continueCourse), minHeight: 5, backgroundColor: AppTheme.paleBlue, color: AppTheme.blue)),
                ])),
                const SizedBox(width: 8),
                Text('${(store.progressFor(continueCourse) * 100).round()}%', style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
              ]))),
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: 'Popular Courses', action: 'View all', onTap: () => onExplore?.call()),
            const SizedBox(height: 10),
            ...store.courses.take(4).map((course) => Padding(padding: const EdgeInsets.only(bottom: 9), child: CourseCard(course: course, compact: true, onTap: () => _openCourse(context, course)))),
          ]);
        },
      );

  void _openCourse(BuildContext context, CourseModel course) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course)));
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;
  late final List<Widget> _pages;
  @override
  void initState() { super.initState(); _index = widget.initialTab; _pages = [HomeTab(onExplore: () => setState(() => _index = 1)), const ExploreTab(), const DownloadsTab(), ProfileTab(onDownloads: () => setState(() => _index = 2))]; }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: IndexedStack(index: _index, children: _pages)),
    bottomNavigationBar: BottomNavigationBar(currentIndex: _index, onTap: (v) => setState(() => _index = v), items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Explore'),
      BottomNavigationBarItem(icon: Icon(Icons.download_outlined), activeIcon: Icon(Icons.download_rounded), label: 'Downloads'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
    ]),
  );
}

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});
  @override
  State<ExploreTab> createState() => _ExploreTabState();
}
class _ExploreTabState extends State<ExploreTab> {
  final _search = TextEditingController();
  String _category = 'All';
  final _categories = const ['All', 'Programming', 'Design', 'Security'];
  @override
  void dispose() { _search.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: LearnFlowStore.instance, builder: (context, _) {
    final courses = LearnFlowStore.instance.courses.where((course) {
      final matchesCategory = _category == 'All' || course.category.toLowerCase().contains(_category.toLowerCase()) || (_category == 'Security' && course.title.toLowerCase().contains('security'));
      final q = _search.text.trim().toLowerCase();
      return matchesCategory && (q.isEmpty || course.title.toLowerCase().contains(q) || course.description.toLowerCase().contains(q));
    }).toList();
    return ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 24), children: [
      const Text('Explore Courses', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: AppTheme.ink)),
      const SizedBox(height: 16),
      TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Search courses...', suffixIcon: Icon(Icons.tune_rounded))),
      const SizedBox(height: 12),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _categories.map((category) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(category), selected: _category == category, onSelected: (_) => setState(() => _category = category), showCheckmark: false, selectedColor: AppTheme.paleBlue, backgroundColor: Colors.white, side: BorderSide.none, labelStyle: TextStyle(color: _category == category ? AppTheme.blue : AppTheme.muted, fontWeight: FontWeight.w700, fontSize: 12)))).toList())),
      const SizedBox(height: 14),
      if (courses.isEmpty)
        const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No courses found. Try another search.', style: TextStyle(color: AppTheme.muted))),
        )
      else
        ...courses.map((course) => Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: CourseCard(
            course: course,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course)),
            ),
          ),
        )),
    ]);
  });
}

class DownloadsTab extends StatefulWidget {
  const DownloadsTab({super.key});
  @override
  State<DownloadsTab> createState() => _DownloadsTabState();
}

class _DownloadsTabState extends State<DownloadsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: LearnFlowStore.instance,
        builder: (context, _) {
          final store = LearnFlowStore.instance;
          final completedItems = store.downloadedPaths.keys
              .map(store.lessonById)
              .whereType<LessonModel>()
              .toList();
          final activeIds = store.downloadingIds.toList();

          // Estimated storage: 18 MB per downloaded video
          const maxStorageMb = 10240; // 10 GB
          final usedMb = completedItems.length * 18;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Downloads',
                        style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: AppTheme.ink),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showStorageDialog(context, usedMb, maxStorageMb),
                      icon: const Icon(Icons.storage_outlined),
                      tooltip: 'Storage info',
                    ),
                    if (completedItems.isNotEmpty)
                      IconButton(
                        onPressed: () => _confirmClearAll(context, store),
                        icon: const Icon(Icons.delete_outline_rounded),
                        tooltip: 'Clear all downloads',
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: AppTheme.line,
                  indicatorColor: AppTheme.blue,
                  labelColor: AppTheme.blue,
                  unselectedLabelColor: AppTheme.muted,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  tabs: [
                    Tab(text: 'Downloading (${activeIds.length})'),
                    Tab(text: 'Completed (${completedItems.length})'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // --- Downloading tab ---
                    activeIds.isEmpty
                        ? const _EmptyState(
                            icon: Icons.downloading_rounded,
                            title: 'Nothing downloading',
                            subtitle: 'Start a download from any course page.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                            itemCount: activeIds.length,
                            itemBuilder: (context, i) {
                              final id = activeIds[i];
                              final lesson = store.lessonById(id);
                              if (lesson == null) return const SizedBox.shrink();
                              final progress = store.downloadProgress[id] ?? 0;
                              final downloadedMb =
                                  (progress * 18).toStringAsFixed(1);
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              lesson.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
                                              borderRadius:
                                                  BorderRadius.circular(6),
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
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.pause_circle_outline_rounded,
                                          color: AppTheme.blue,
                                        ),
                                        tooltip: 'Cancel',
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                    // --- Completed tab ---
                    completedItems.isEmpty
                        ? const _EmptyDownloads()
                        : ListView(
                            padding:
                                const EdgeInsets.fromLTRB(18, 14, 18, 24),
                            children: [
                              ...completedItems.map((lesson) {
                                final course =
                                    store.courseForLesson(lesson.id);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 9),
                                  child: Card(
                                    child: ListTile(
                                      leading: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE1F6EE),
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                        '${course?.title ?? 'Course video'} • Completed • 18 MB',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.muted,
                                        ),
                                      ),
                                      trailing: PopupMenuButton<String>(
                                        onSelected: (v) async {
                                          if (v == 'remove') {
                                            await store.removeDownload(
                                                lesson.id);
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
                                                  builder: (_) =>
                                                      VideoPlayerScreen(
                                                    course: course,
                                                    lessons: store
                                                        .lessonsFor(course),
                                                    initialIndex: store
                                                        .lessonsFor(course)
                                                        .indexWhere((l) =>
                                                            l.id == lesson.id),
                                                  ),
                                                ),
                                              ),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 10),
                              // Storage usage bar
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
                                        const Icon(
                                          Icons.storage_outlined,
                                          size: 16,
                                          color: AppTheme.muted,
                                        ),
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
                                          '$usedMb MB / ${(maxStorageMb / 1024).round()} GB',
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
                                        value: usedMb / maxStorageMb,
                                        minHeight: 6,
                                        color: AppTheme.blue,
                                        backgroundColor: AppTheme.paleBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          );
        },
      );

  void _showStorageDialog(
      BuildContext context, int usedMb, int maxStorageMb) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Storage Info'),
        content: Text(
            'Using ~$usedMb MB of estimated ${maxStorageMb ~/ 1024} GB app storage.\n\nDownloaded videos are stored in private app storage and can be removed individually or cleared from this screen.'),
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
            'This will remove all downloaded videos from this device. You can re-download them anytime.'),
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

class _EmptyDownloads extends StatelessWidget {
  const _EmptyDownloads();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: const [
            Icon(Icons.download_for_offline_outlined, size: 44, color: AppTheme.blue),
            SizedBox(height: 12),
            Text('No downloads yet', style: TextStyle(fontWeight: FontWeight.w800)),
            SizedBox(height: 5),
            Text('Your saved lessons will appear here.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted, fontSize: 12)),
          ],
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: AppTheme.blue),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
            ],
          ),
        ),
      );
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, this.onDownloads});
  final VoidCallback? onDownloads;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: LearnFlowStore.instance, builder: (context, _) {
    final store = LearnFlowStore.instance;
    final totalLessons = store.courses.fold<int>(0, (sum, course) => sum + course.totalLessons);
    return ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 24), children: [
      const Text('Profile', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: AppTheme.ink)),
      const SizedBox(height: 16),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [CircleAvatar(radius: 28, backgroundColor: AppTheme.paleBlue, child: Text(store.userName.isEmpty ? 'L' : store.userName[0].toUpperCase(), style: const TextStyle(color: AppTheme.blue, fontWeight: FontWeight.w800, fontSize: 21))), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(store.userName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)), const SizedBox(height: 4), Text(store.userEmail, style: const TextStyle(color: AppTheme.muted, fontSize: 12))])), IconButton(onPressed: () => _editName(context, store.userName), icon: const Icon(Icons.edit_outlined, color: AppTheme.blue))]))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Expanded(child: _Stat(value: '${store.courses.length}', label: 'Courses')), Expanded(child: _Stat(value: '${store.completedLessonIds.length}', label: 'Completed')), Expanded(child: _Stat(value: '${_learningHours(store)}h', label: 'Learning Time'))]))),
      const SizedBox(height: 22),
      const Text('Learning', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 7),
      _ProfileAction(icon: Icons.insights_outlined, title: 'My Learning Progress', onTap: () => _showProgress(context)),
      _ProfileAction(icon: Icons.download_outlined, title: 'Downloads', onTap: () => onDownloads?.call()),
      _ProfileAction(icon: Icons.settings_outlined, title: 'Settings', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()))),
      _ProfileAction(icon: Icons.help_outline_rounded, title: 'Help & Support', onTap: () => showAboutDialog(context: context, applicationName: 'LearnFlow', applicationVersion: '1.0.0', children: const [Text('LearnFlow student learning app prototype.') ])),
      const SizedBox(height: 12),
      Card(child: ListTile(leading: const Icon(Icons.logout_rounded, color: Color(0xFFE14D5A)), title: const Text('Logout', style: TextStyle(color: Color(0xFFE14D5A), fontWeight: FontWeight.w800)), onTap: () async { await store.signOut(); if (context.mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false); })),
      const SizedBox(height: 12),
      Center(child: Text('LearnFlow • $totalLessons lessons available', style: const TextStyle(color: AppTheme.muted, fontSize: 11))),
    ]);
  });

  void _editName(BuildContext context, String current) { final controller = TextEditingController(text: current); showDialog(context: context, builder: (dialogContext) => AlertDialog(title: const Text('Edit profile name'), content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Your name')), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')), TextButton(onPressed: () async { final value = controller.text.trim(); if (value.length >= 2) await LearnFlowStore.instance.signIn(LearnFlowStore.instance.userEmail, name: value); if (dialogContext.mounted) Navigator.pop(dialogContext); }, child: const Text('Save'))])); }
  void _showProgress(BuildContext context) { final store = LearnFlowStore.instance; showModalBottomSheet(context: context, showDragHandle: true, builder: (_) => ListView(padding: const EdgeInsets.all(18), children: [const Text('My Learning Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 14), ...store.courses.map((course) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(course.title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 7), LinearProgressIndicator(value: store.progressFor(course), minHeight: 6, color: AppTheme.blue, backgroundColor: AppTheme.paleBlue), const SizedBox(height: 4), Text('${store.completedCountFor(course)} of ${course.totalLessons} lessons completed', style: const TextStyle(fontSize: 11, color: AppTheme.muted))]))) ])); }

  int _learningHours(LearnFlowStore store) {
    int totalMinutes = 0;
    for (final course in store.courses) {
      for (final lesson in store.lessonsFor(course)) {
        if (store.completedLessonIds.contains(lesson.id)) {
          // Parse "MM:SS" duration
          final parts = lesson.duration.split(':');
          if (parts.length == 2) {
            totalMinutes += int.tryParse(parts[0]) ?? 0;
          }
        }
      }
    }
    return (totalMinutes / 60).ceil();
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label}); final String value; final String label;
  @override Widget build(BuildContext context) => Column(children: [Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.ink)), const SizedBox(height: 4), Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 11))]);
}
class _ProfileAction extends StatelessWidget {
  const _ProfileAction({required this.icon, required this.title, required this.onTap}); final IconData icon; final String title; final VoidCallback onTap;
  @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 7), child: ListTile(dense: true, leading: Icon(icon, color: AppTheme.blue, size: 21), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)), trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.muted), onTap: onTap));
}
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.action, required this.onTap}); final String title; final String action; final VoidCallback onTap;
  @override Widget build(BuildContext context) => Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink))), TextButton(onPressed: onTap, child: Text(action, style: const TextStyle(fontSize: 12)))]);
}
class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.onTap}); final VoidCallback onTap;
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(13), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: AppTheme.line)), child: const Row(children: [Icon(Icons.search_rounded, color: AppTheme.ink, size: 20), SizedBox(width: 10), Expanded(child: Text('Search courses...', style: TextStyle(color: AppTheme.muted, fontSize: 13))), Icon(Icons.tune_rounded, color: AppTheme.muted, size: 18)])));
}
