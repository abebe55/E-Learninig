import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elearning_app/app/app_theme.dart';

void main() {
  test('LearnFlow primary and secondary buttons have white fills and no outline', () {
    final theme = AppTheme.light;
    final primary = theme.elevatedButtonTheme.style!;
    final secondary = theme.outlinedButtonTheme.style!;

    expect(primary.backgroundColor!.resolve({}), Colors.white);
    expect(primary.foregroundColor!.resolve({}), AppTheme.blue);
    expect((primary.shape!.resolve({}) as RoundedRectangleBorder).side, BorderSide.none);

    expect(secondary.backgroundColor!.resolve({}), Colors.white);
    expect(secondary.foregroundColor!.resolve({}), AppTheme.blue);
    expect(secondary.side!.resolve({}), BorderSide.none);
    expect((secondary.shape!.resolve({}) as RoundedRectangleBorder).side, BorderSide.none);
  });

  testWidgets('login and guest button labels render', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Column(children: [
        ElevatedButton(onPressed: () {}, child: const Text('Login')),
        OutlinedButton(onPressed: () {}, child: const Text('Guest')),
      ])),
    ));
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Guest'), findsOneWidget);
  });
}
