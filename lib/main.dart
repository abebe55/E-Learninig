import 'package:flutter/material.dart';
import 'app/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/learnflow_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LearnFlowStore.instance.initialize();
  runApp(const LearnFlowApp());
}

class LearnFlowApp extends StatelessWidget {
  const LearnFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearnFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
