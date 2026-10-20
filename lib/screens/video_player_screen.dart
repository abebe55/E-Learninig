import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../app/app_theme.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';
import '../services/learnflow_store.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    super.key,
    required this.course,
    required this.lessons,
    required this.initialIndex,
  });
  final CourseModel course;
  final List<LessonModel> lessons;
  final int initialIndex;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _vpc;
  ChewieController? _cc;
  int _index = 0;
  bool _loading = true;
  bool _error = false;
  String _errorMsg = '';
  bool _isOffline = false;
  late TabController _tabs;
  bool _showNotes = false;

  LessonModel get _lesson => widget.lessons[_index];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _index = widget.initialIndex.clamp(0, widget.lessons.length - 1);
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    setState(() {
      _loading = true;
      _error = false;
      _isOffline = false;
    });

    // Dispose previous controllers
    _cc?.dispose();
    _cc = null;
    _vpc?.dispose();
    _vpc = null;

    try {
      VideoPlayerController vpc;

      // 1. Try local downloaded file first (works offline)
      final store = LearnFlowStore.instance;
      final localPath = store.downloadedPath(_lesson.id);
      if (localPath != null) {
        final f = File(localPath);
        if (await f.exists()) {
          vpc = VideoPlayerController.file(f);
          _isOffline = true;
          await _finishInit(vpc);
          return;
        }
      }

      // 2. Stream from network
      _isOffline = false;
      vpc = VideoPlayerController.networkUrl(
        Uri.parse(_lesson.videoUrl),
        httpHeaders: const {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          'Accept': 'video/mp4,video/*,*/*;q=0.9',
          'Accept-Encoding': 'identity',
        },
      );
      await _finishInit(vpc);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
        _errorMsg = _friendlyError(e.toString());
      });
    }
  }

  Future<void> _finishInit(VideoPlayerController vpc) async {
    await vpc.initialize();
    final cc = ChewieController(
      videoPlayerController: vpc,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControlsOnInitialize: true,
      allowPlaybackSpeedChanging: true,
      playbackSpeeds: const [0.5, 1.0, 1.25, 1.5, 2.0],
      materialProgressColors: ChewieProgressColors(
        playedColor: AppTheme.blue,
        handleColor: AppTheme.blue,
        backgroundColor: Colors.white24,
        bufferedColor: AppTheme.blue.withOpacity(0.35),
      ),
    );
    if (!mounted) {
      cc.dispose();
      vpc.dispose();
      return;
    }
    setState(() {
      _vpc = vpc;
      _cc = cc;
      _loading = false;
    });
  }

  String _friendlyError(String raw) {
    if (raw.contains('403') || raw.contains('401')) {
      return 'Video server blocked the request.\nDownload this lesson to watch offline.';
    }
    if (raw.contains('404')) {
      return 'Video not found.\nCheck your connection or try again.';
    }
    if (raw.contains('SocketException') ||
        raw.contains('network') ||
        raw.contains('connection')) {
      return 'No internet connection.\nDownload this lesson first to watch offline.';
    }
    return 'Could not load video.\nCheck your connection or download the lesson.';
  }

  @override
  void dispose() {
    _cc?.dispose();
    _vpc?.dispose();
    _tabs.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          _lesson.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_isOffline)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('Offline',
                    style: TextStyle(fontSize: 11, color: Colors.white)),
                backgroundColor: AppTheme.green,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          AnimatedBuilder(
            animation: LearnFlowStore.instance,
            builder: (context, _) {
              final store = LearnFlowStore.instance;
              final downloaded = store.isDownloaded(_lesson.id);
              final downloading =
                  store.downloadingIds.contains(_lesson.id);
              if (downloaded) {
                return const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.download_done_rounded,
                      color: AppTheme.green),
                );
              }
              if (downloading) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return IconButton(
                onPressed: _download,
                icon: const Icon(Icons.download_for_offline_outlined),
                tooltip: 'Download for offline',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Video area ──────────────────────────────────────
          Container(
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Colors.white))
                  : _error
                      ? _buildErrorWidget()
                      : Chewie(controller: _cc!),
            ),
          ),

          // ── Content below ────────────────────────────────────
          Expanded(
            child: AnimatedBuilder(
              animation: LearnFlowStore.instance,
              builder: (context, _) {
                final store = LearnFlowStore.instance;
                final isComplete =
                    store.completedLessonIds.contains(_lesson.id);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + subtitle
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _lesson.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.course.title} · Chapter ${_chapterLabel()} · Lesson ${_index + 1} of ${widget.lessons.length}',
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.muted),
                          ),
                        ],
                      ),
                    ),

                    // Description / Notes tab bar
                    TabBar(
                      controller: _tabs,
                      labelColor: AppTheme.blue,
                      unselectedLabelColor: AppTheme.muted,
                      indicatorColor: AppTheme.blue,
                      indicatorSize: TabBarIndicatorSize.tab,
                      onTap: (i) =>
                          setState(() => _showNotes = i == 1),
                      tabs: const [
                        Tab(text: 'Description'),
                        Tab(text: 'Notes'),
                      ],
                    ),

                    Expanded(
                      child: TabBarView(
                        controller: _tabs,
                        children: [
                          // Description
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'In this lesson you will learn the key ideas in ${_lesson.title.toLowerCase()}. '
                              'Follow along with the video, pause when needed, and mark the lesson complete when you are ready.',
                              style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: AppTheme.ink),
                            ),
                          ),
                          // Notes
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: _NotesBox(),
                          ),
                        ],
                      ),
                    ),

                    // Bottom bar
                    Container(
                      padding:
                          const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: AppTheme.line),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                await store.markCompleted(
                                  _lesson.id,
                                  completed: !isComplete,
                                );
                              },
                              child: Text(isComplete
                                  ? '✓ Completed — Mark Incomplete'
                                  : '✓ Mark as Complete'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _index > 0
                                      ? () => _changeLesson(
                                          _index - 1)
                                      : null,
                                  icon: const Icon(
                                      Icons.chevron_left_rounded),
                                  label: const Text('Previous'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _index <
                                          widget.lessons.length - 1
                                      ? () => _changeLesson(
                                          _index + 1)
                                      : null,
                                  icon: const Icon(
                                      Icons.chevron_right_rounded),
                                  label: const Text('Next'),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    final store = LearnFlowStore.instance;
    final downloaded = store.isDownloaded(_lesson.id);
    final downloading = store.downloadingIds.contains(_lesson.id);
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam_off_outlined,
              color: Colors.white54, size: 52),
          const SizedBox(height: 16),
          Text(
            _errorMsg,
            style: const TextStyle(
                color: Colors.white70, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _initPlayer,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Retry',
                    style: TextStyle(color: Colors.white)),
              ),
              if (!downloaded && !downloading) ...[
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: _download,
                  icon: const Icon(Icons.download_outlined,
                      color: AppTheme.green),
                  label: const Text('Download',
                      style: TextStyle(color: AppTheme.green)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _chapterLabel() {
    for (final chapter in widget.course.chapters) {
      for (final l in chapter.lessons) {
        if (l.id == _lesson.id) {
          return (widget.course.chapters.indexOf(chapter) + 1)
              .toString();
        }
      }
    }
    return '1';
  }

  Future<void> _changeLesson(int index) async {
    if (index < 0 || index >= widget.lessons.length) return;
    setState(() => _index = index);
    await _initPlayer();
  }

  Future<void> _download() async {
    try {
      await LearnFlowStore.instance.downloadLesson(_lesson);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${_lesson.title} saved for offline viewing.'),
          backgroundColor: AppTheme.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('SocketException')
            ? 'No internet. Connect and try again.'
            : 'Download failed. Check your connection.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFFE14D5A),
        ));
      }
    }
  }
}

class _NotesBox extends StatelessWidget {
  const _NotesBox();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.line),
        ),
        child: const Text(
          'Your notes for this lesson can be written here in a future version.',
          style: TextStyle(
              color: AppTheme.muted, fontSize: 12, height: 1.5),
        ),
      );
}
