import 'dart:async';
import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../services/learnflow_store.dart';
import 'auth_screen.dart';
import 'main_shell.dart';

/// Minimal branded splash matching the supplied LearnFlow student design.
/// It intentionally contains no outlined CTA button.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 35), (timer) {
      if (!mounted) return;
      setState(() => _progress = (_progress + .025).clamp(0, 1).toDouble());
      if (_progress >= 1) {
        timer.cancel();
        final store = LearnFlowStore.instance;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                store.isSignedIn ? const MainShell() : const AuthScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x102878F0),
                        blurRadius: 24,
                        offset: Offset(0, 7),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset('assets/images/app_icon.png', fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 15),
                const Text('LearnFlow',
                    style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink)),
                const SizedBox(height: 12),
                const Text('Learn Today\nBuild Tomorrow',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        height: 1.35,
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 17),
                const Text('Your learning journey\nstarts here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppTheme.muted, fontSize: 12, height: 1.5)),
                const SizedBox(height: 18),
                Expanded(
                  flex: 4,
                  child: Image.asset('assets/images/splash_learner.png',
                      fit: BoxFit.contain),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 110,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 3,
                      backgroundColor: AppTheme.paleBlue,
                      color: AppTheme.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
