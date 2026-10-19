import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';

class LearnFlowStore extends ChangeNotifier {
  LearnFlowStore._();
  static final LearnFlowStore instance = LearnFlowStore._();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 10),
    headers: {
      'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      'Accept': '*/*',
    },
  ));
  SharedPreferences? _prefs;
  List<CourseModel> courses = [];
  final Set<String> completedLessonIds = {};
  final Map<String, String> downloadedPaths = {};
  final Map<String, double> downloadProgress = {};
  final Set<String> downloadingIds = {};
  String userName = 'Abebe Marye';
  String userEmail = 'abebe@example.com';
  bool isSignedIn = false;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = await rootBundle.loadString('assets/data/courses.json');
    final parsed = jsonDecode(raw) as Map<String, dynamic>;
    courses = (parsed['courses'] as List<dynamic>)
        .map((item) => CourseModel.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
    completedLessonIds.addAll(_prefs!.getStringList('completed_lessons') ?? const []);
    final savedDownloads = _prefs!.getString('downloaded_lessons');
    if (savedDownloads != null) {
      final map = jsonDecode(savedDownloads) as Map<String, dynamic>;
      for (final entry in map.entries) {
        final file = File(entry.value as String);
        if (await file.exists()) downloadedPaths[entry.key] = entry.value as String;
      }
    }
    userName = _prefs!.getString('profile_name') ?? userName;
    userEmail = _prefs!.getString('profile_email') ?? userEmail;
    isSignedIn = _prefs!.getBool('signed_in') ?? false;
  }

  List<LessonModel> lessonsFor(CourseModel course) => course.chapters.expand((chapter) => chapter.lessons).toList();
  int completedCountFor(CourseModel course) => lessonsFor(course).where((lesson) => completedLessonIds.contains(lesson.id)).length;
  double progressFor(CourseModel course) {
    final total = course.totalLessons;
    return total == 0 ? 0 : completedCountFor(course) / total;
  }

  Future<void> markCompleted(String lessonId, bool value) async {
    if (value) {
      completedLessonIds.add(lessonId);
    } else {
      completedLessonIds.remove(lessonId);
    }
    await _prefs?.setStringList('completed_lessons', completedLessonIds.toList());
    notifyListeners();
  }

  Future<void> signIn(String email, {String? name}) async {
    userEmail = email.trim();
    userName = (name?.trim().isNotEmpty ?? false) ? name!.trim() : _nameFromEmail(userEmail);
    isSignedIn = true;
    await _prefs?.setString('profile_email', userEmail);
    await _prefs?.setString('profile_name', userName);
    await _prefs?.setBool('signed_in', true);
    notifyListeners();
  }

  Future<void> signOut() async {
    isSignedIn = false;
    await _prefs?.setBool('signed_in', false);
    notifyListeners();
  }

  String _nameFromEmail(String email) {
    final local = email.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ').trim();
    if (local.isEmpty) return 'Learner';
    return local.split(' ').map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}').join(' ');
  }

  bool isDownloaded(String lessonId) => downloadedPaths.containsKey(lessonId) && File(downloadedPaths[lessonId]!).existsSync();

  Future<void> downloadLesson(LessonModel lesson) async {
    if (isDownloaded(lesson.id) || downloadingIds.contains(lesson.id)) return;
    downloadingIds.add(lesson.id);
    downloadProgress[lesson.id] = 0;
    notifyListeners();
    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${directory.path}/learnflow_downloads');
      if (!await downloadDir.exists()) await downloadDir.create(recursive: true);
      final safeName = lesson.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final target = '${downloadDir.path}/$safeName.mp4';

      // Remove any partial file from a previous attempt
      final tempFile = File(target);
      if (await tempFile.exists()) await tempFile.delete();

      await _dio.download(
        lesson.videoUrl,
        target,
        deleteOnError: true,
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
          receiveDataWhenStatusError: false,
          headers: {
            'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
            'Accept': 'video/mp4,video/*,*/*',
            'Range': 'bytes=0-',
          },
        ),
        onReceiveProgress: (received, total) {
          if (total > 0) {
            downloadProgress[lesson.id] = (received / total).clamp(0.0, 1.0);
          } else {
            // Unknown total — show indeterminate progress based on bytes
            downloadProgress[lesson.id] = (received / (received + 1024 * 1024)).clamp(0.0, 0.99);
          }
          notifyListeners();
        },
      );

      final file = File(target);
      if (!await file.exists()) throw Exception('Download completed but file not found.');
      final fileSize = await file.length();
      if (fileSize < 1024) {
        await file.delete();
        throw Exception('Downloaded file is too small (${fileSize} bytes). The server may have rejected the request.');
      }

      downloadProgress[lesson.id] = 1.0;
      downloadedPaths[lesson.id] = target;
      await _prefs?.setString('downloaded_lessons', jsonEncode(downloadedPaths));
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
    await _prefs?.setString('downloaded_lessons', jsonEncode(downloadedPaths));
    notifyListeners();
  }

  String? downloadedPath(String lessonId) => isDownloaded(lessonId) ? downloadedPaths[lessonId] : null;
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
      if (lessonsFor(course).any((lesson) => lesson.id == lessonId)) return course;
    }
    return null;
  }
}
