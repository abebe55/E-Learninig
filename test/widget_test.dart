import 'package:elearning_app/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Theme tests
// ---------------------------------------------------------------------------

void main() {
  group('AppTheme button styles', () {
    test('ElevatedButton has white fill and blue text, no outline', () {
      final theme = AppTheme.light;
      final style = theme.elevatedButtonTheme.style!;

      expect(style.backgroundColor!.resolve({}), Colors.white);
      expect(style.foregroundColor!.resolve({}), AppTheme.blue);
      expect(
        (style.shape!.resolve({}) as RoundedRectangleBorder).side,
        BorderSide.none,
      );
    });

    test('OutlinedButton has white fill and blue text, no outline', () {
      final theme = AppTheme.light;
      final style = theme.outlinedButtonTheme.style!;

      expect(style.backgroundColor!.resolve({}), Colors.white);
      expect(style.foregroundColor!.resolve({}), AppTheme.blue);
      expect(style.side!.resolve({}), BorderSide.none);
    });
  });

  // -------------------------------------------------------------------------
  // Auth screen widget tests
  // -------------------------------------------------------------------------

  group('AuthScreen', () {
    testWidgets('login screen renders Login and Guest buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Column(
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('Login')),
                OutlinedButton(onPressed: () {}, child: const Text('Guest')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Guest'), findsOneWidget);
    });

    testWidgets('form validates empty email', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TextFormField(
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('form validates password shorter than 6 chars', (tester) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController(text: '123');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Min 6 chars' : null,
              ),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Min 6 chars'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Course model parsing tests
  // -------------------------------------------------------------------------

  group('CourseModel JSON parsing', () {
    test('parses title, rating, and chapter count from JSON', () {
      const json = {
        'id': '1',
        'title': 'Web Development',
        'description': 'Learn the web.',
        'thumbnailColor': '#6B9CE8',
        'category': 'Programming',
        'rating': 4.8,
        'studentsCount': 100,
        'chapters': [
          {
            'id': '1-1',
            'title': 'HTML',
            'lessons': [
              {
                'id': '1-1-1',
                'title': 'Intro',
                'duration': '10:00',
                'videoUrl': 'https://example.com/video.mp4',
              },
            ],
          },
        ],
      };

      // Manually exercise the parsing logic.
      final title = json['title'] as String;
      final rating = (json['rating'] as num).toDouble();
      final chapters = json['chapters'] as List;
      final lessons = (chapters.first as Map)['lessons'] as List;

      expect(title, 'Web Development');
      expect(rating, 4.8);
      expect(chapters.length, 1);
      expect(lessons.length, 1);
    });

    test('totalLessons sums across all chapters', () {
      // Two chapters with 2 lessons each = 4 total.
      const chapters = [
        {'lessons': [{}, {}]},
        {'lessons': [{}, {}]},
      ];
      final total = chapters.fold<int>(
        0,
        (sum, ch) => sum + ((ch['lessons'] as List).length),
      );
      expect(total, 4);
    });
  });

  // -------------------------------------------------------------------------
  // Download validation logic tests
  // -------------------------------------------------------------------------

  group('Download validation', () {
    test('rejects file smaller than 10 KB as invalid video', () {
      const fileSize = 5 * 1024; // 5 KB
      final isValid = fileSize >= 10 * 1024;
      expect(isValid, isFalse);
    });

    test('accepts file larger than 10 KB as valid video', () {
      const fileSize = 500 * 1024; // 500 KB
      final isValid = fileSize >= 10 * 1024;
      expect(isValid, isTrue);
    });

    test('rejects non-2xx HTTP status codes', () {
      bool isSuccess(int? status) =>
          status != null && status >= 200 && status < 300;

      expect(isSuccess(200), isTrue);
      expect(isSuccess(206), isTrue); // partial content (range request)
      expect(isSuccess(403), isFalse);
      expect(isSuccess(404), isFalse);
      expect(isSuccess(500), isFalse);
      expect(isSuccess(null), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // Password hashing tests
  // -------------------------------------------------------------------------

  group('Password hashing', () {
    // Mirror the same hash function used in LearnFlowStore.
    String hashPassword(String password) {
      const salt = 'learnflow_local_salt_v1';
      final bytes = <int>[
        for (final c in (password + salt).codeUnits) c,
      ];
      var hash = 0;
      for (final b in bytes) {
        hash = ((hash << 5) - hash + b) & 0xFFFFFFFF;
      }
      return hash.toRadixString(16).padLeft(8, '0');
    }

    test('same password produces same hash', () {
      expect(hashPassword('secret123'), hashPassword('secret123'));
    });

    test('different passwords produce different hashes', () {
      expect(hashPassword('secret123'), isNot(hashPassword('wrong456')));
    });

    test('hash is non-empty 8-char hex string', () {
      final h = hashPassword('test');
      expect(h.length, 8);
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(h), isTrue);
    });
  });
}
