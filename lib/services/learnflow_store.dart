import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/course_model.dart';
import '../models/lesson_model.dart';

/// Central app state using ChangeNotifier (simple, no extra packages).
///
/// Responsibilities:
///  - Auth: register, login, guest access, logout (local mock only)
///  - Course data: loaded once from bundled JSON
///  - Lesson progress: completed lesson IDs persisted locally
///  - Video downloads: download, track progress, persist paths
class LearnFlowStore extends ChangeNotifier {
  LearnFlowStore._();
  static final LearnFlowStore instance = LearnFlowStore._();

  // ── HTTP client ───────────────────────────────────────────────────────────

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 10),
    ),
  );

  // ── State ─────────────────────────────────────────────────────────────────

  SharedPreferences? _prefs;

  List<CourseModel> courses = [];
  final Set<String> completedLessonIds = {};
  final Map<String, String> downloadedPaths = {};
  final Map<String, double> downloadProgress = {};
  final Set<String> downloadingIds = {};

  String userName = '';
  String userEmail = '';
  bool isSignedIn = false;

  // ── Initialisation ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    // Load course catalog from bundled JSON asset.
    final raw = await rootBundle.loadString('assets/data/courses.json');
    final parsed = jsonDecode(raw) as Map<String, dynamic>;
    courses = (parsed['courses'] as List<dynamic>)
        .map((item) => CourseModel.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    // Restore persisted state.
    completedLessonIds.addAll(
      _prefs!.getStringList('completed_lessons') ?? const [],
    );

    final savedDownloads = _prefs!.getString('downloaded_lessons');
    if (savedDownloads != null) {
      final map = jsonDecode(savedDownloads) as Map<String, dynamic>;
      for (final entry in map.entries) {
        final file = File(entry.value as String);
        if (await file.exists()) {
          downloadedPaths[entry.key] = entry.value as String;
        }
      }
    }

    userName = _prefs!.getString('profile_name') ?? '';
    userEmail = _prefs!.getString('profile_email') ?? '';
    isSignedIn = _prefs!.getBool('signed_in') ?? false;
  }

  // ── Authentication ────────────────────────────────────────────────────────

  /// Registers a new mock user. Stores a simple hash of the password so the
  /// same credential is required on subsequent logins.
  ///
  /// Returns null on success, or an error string if the email is already taken.
  Future<String?> register(String email, String password, String name) async {
    final key = 'user_${email.trim().toLowerCase()}';
    if (_prefs!.containsKey(key)) {
      return 'An account with this email already exists.';
    }
    // Store a basic hash — not cryptographically strong, but sufficient for a
    // local prototype that never transmits credentials.
    final hash = _hashPassword(password);
    await _prefs!.setString(key, jsonEncode({'name': name.trim(), 'hash': hash}));
    await _applySession(email: email.trim(), name: name.trim());
    return null;
  }

  /// Verifies credentials against the locally stored mock user record.
  ///
  /// Returns null on success, or an error string on failure.
  Future<String?> login(String emailOrUsername, String password) async {
    final email = emailOrUsername.trim().toLowerCase();
    final key = 'user_$email';

    if (!_prefs!.containsKey(key)) {
      return 'No account found for that email. Please register first.';
    }

    final stored = jsonDecode(_prefs!.getString(key)!) as Map<String, dynamic>;
    final expectedHash = stored['hash'] as String;

    if (_hashPassword(password) != expectedHash) {
      return 'Incorrect password. Please try again.';
    }

    await _applySession(
      email: email,
      name: stored['name'] as String? ?? _nameFromEmail(email),
    );
    return null;
  }

  /// Signs in as a guest without credentials.
  Future<void> loginAsGuest() async {
    await _applySession(
      email: 'guest@learnflow.local',
      name: 'Guest Learner',
    );
  }

  Future<void> signOut() async {
    isSignedIn = false;
    await _prefs?.setBool('signed_in', false);
    notifyListeners();
  }

  /// Updates profile name without changing auth credentials.
  Future<void> updateProfileName(String name) async {
    userName = name.trim();
    await _prefs?.setString('profile_name', userName);
    notifyListeners();
  }

  Future<void> _applySession({
    required String email,
    required String name,
  }) async {
    userEmail = email;
    userName = name;
    isSignedIn = true;
    await _prefs?.setString('profile_email', userEmail);
    await _prefs?.setString('profile_name', userName);
    await _prefs?.setBool('signed_in', true);
    notifyListeners();
  }

  /// Produces a deterministic string from a password.
  /// Uses a salted XOR-fold — adequate for a local prototype only.
  String _hashPassword(String password) {
    const salt = 'learnflow_local_salt_v1';
    final bytes = utf8.encode(password + salt);
    var hash = 0;
    for (final b in bytes) {
      hash = ((hash << 5) - hash + b) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  String _nameFromEmail(String email) {
    final local = email
        .split('@')
        .first
        .replaceAll(RegExp(r'[._-]+'), ' ')
        .trim();
    if (local.isEmpty) return 'Learner';
    return local
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  // ── Course helpers ────────────────────────────────────────────────────────

  List<LessonModel> lessonsFor(CourseModel course) =>
      course.chapters.expand((ch) => ch.lessons).toList();

  int completedCountFor(CourseModel course) =>
      lessonsFor(course)
          .where((l) => completedLessonIds.contains(l.id))
          .length;

  double progressFor(CourseModel course) {
    final total = course.totalLessons;
    return total == 0 ? 0 : completedCountFor(course) / total;
  }

  // ── Progress ──────────────────────────────────────────────────────────────

  Future<void> markCompleted(String lessonId, {required bool completed}) async {
    if (completed) {
      completedLessonIds.add(lessonId);
    } else {
      completedLessonIds.remove(lessonId);
    }
    await _prefs?.setStringList(
      'completed_lessons',
      completedLessonIds.toList(),
    );
    notifyListeners();
  }

  // ── Settings ──────────────────────────────────────────────────────────────

  bool get isOfflineModeEnabled =>
      _prefs?.getBool('offline_mode') ?? false;

  bool get isWifiOnlyDownloads =>
      _prefs?.getBool('wifi_only_downloads') ?? true;

  // ── Downloads ─────────────────────────────────────────────────────────────

  bool isDownloaded(String lessonId) =>
      downloadedPaths.containsKey(lessonId) &&
      File(downloadedPaths[lessonId]!).existsSync();

  String? downloadedPath(String lessonId) =>
      isDownloaded(lessonId) ? downloadedPaths[lessonId] : null;

  Future<void> downloadLesson(LessonModel lesson) async {
    if (isDownloaded(lesson.id) || downloadingIds.contains(lesson.id)) return;

    downloadingIds.add(lesson.id);
    downloadProgress[lesson.id] = 0;
    notifyListeners();

    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${dir.path}/learnflow_downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final safeName = lesson.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final tmpPath = '${downloadDir.path}/$safeName.tmp';
      final finalPath = '${downloadDir.path}/$safeName.mp4';

      // Remove any partial file from a previous failed attempt.
      final tmpFile = File(tmpPath);
      if (await tmpFile.exists()) await tmpFile.delete();

      final response = await _dio.download(
        lesson.videoUrl,
        tmpPath,
        deleteOnError: true,
        options: Options(
          followRedirects: true,
          // Only treat 2xx as success — reject 403/404/etc.
          validateStatus: (status) => status != null && status >= 200 && status < 300,
          headers: const {
            'User-Agent':
                'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36',
            'Accept': 'video/mp4,video/*,*/*;q=0.9',
          },
        ),
        onReceiveProgress: (received, total) {
          final progress = total > 0
              ? (received / total).clamp(0.0, 1.0)
              : (received / (received + 1024 * 1024)).clamp(0.0, 0.99);
          downloadProgress[lesson.id] = progress;
          notifyListeners();
        },
      );

      // Validate: must be 2xx and have enough bytes to be a real video.
      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        throw Exception(
          'Server returned HTTP $statusCode. Download rejected.',
        );
      }

      final downloaded = File(tmpPath);
      if (!await downloaded.exists()) {
        throw Exception('Download completed but file was not saved.');
      }

      final fileSize = await downloaded.length();
      if (fileSize < 10 * 1024) {
        // Less than 10 KB is almost certainly an error page, not a video.
        await downloaded.delete();
        throw Exception(
          'Server returned an invalid file ($fileSize bytes). '
          'This is likely an error page, not a video.',
        );
      }

      // Rename tmp → final only when fully downloaded and validated.
      await downloaded.rename(finalPath);

      downloadProgress[lesson.id] = 1.0;
      downloadedPaths[lesson.id] = finalPath;
      await _prefs?.setString(
        'downloaded_lessons',
        jsonEncode(downloadedPaths),
      );
    } catch (error) {
      downloadProgress.remove(lesson.id);
      rethrow;
    } finally {
      downloadingIds.remove(lesson.id);
      notifyListeners();
    }
  }

  Future<void> removeDownload(String lessonId) async {
    final path = downloadedPaths.remove(lessonId);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    downloadProgress.remove(lessonId);
    await _prefs?.setString(
      'downloaded_lessons',
      jsonEncode(downloadedPaths),
    );
    notifyListeners();
  }

  // ── Lookup helpers ────────────────────────────────────────────────────────

  LessonModel? lessonById(String id) {
    for (final course in courses) {
      for (final lesson in lessonsFor(course)) {
        if (lesson.id == id) return lesson;
      }
    }
    return null;
  }

  CourseModel? courseForLesson(String lessonId) {
    for (final course in courses) {
      if (lessonsFor(course).any((l) => l.id == lessonId)) return course;
    }
    return null;
  }
}
