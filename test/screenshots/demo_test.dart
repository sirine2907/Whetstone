// Records the frames for docs/demo.gif.
// Run: flutter test test/screenshots/demo_test.dart --update-goldens
// then: python tool/make_demo_gif.py
@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'screenshot_test.dart' show loadFonts, openApp, settle, windows;

int _frame = 0;

// Frames go in build/ because only the finished GIF is committed.
Future<void> frame() async {
  _frame++;
  final name = _frame.toString().padLeft(2, '0');
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../build/demo_frames/$name.png'),
  );
}

Future<void> typeSlowly(WidgetTester tester, String text, List<int> stops) async {
  for (final stop in stops) {
    await tester.enterText(find.byType(TextField).first, text.substring(0, stop));
    await tester.pump();
    await frame();
  }
}

void main() {
  setUpAll(loadFonts);

  testWidgets('demo', (tester) async {
    await openApp(tester, seenWelcome: false);
    await frame();

    await tester.tap(find.text('Get Started'));
    await settle(tester);
    await frame();

    // Type a rough prompt and watch the meter.
    await typeSlowly(tester, 'help me write an email asking for a raise', [8, 22, 41]);

    await tester.tap(find.text('Detailed').first); // the focus tile, not a Recent card
    await settle(tester);
    await frame();

    await tester.tap(find.widgetWithText(FilledButton, 'Sharpen'));
    await settle(tester);
    await frame();

    // Fill in a template and send it to Sharpen.
    await tester.tap(find.byTooltip('Back'));
    await settle(tester);
    await tester.tap(find.byTooltip('Templates'));
    await settle(tester);
    await frame();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Work'));
    await settle(tester);
    await tester.tap(find.text('Weigh Two Options'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).at(0), 'take the remote job');
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(1), 'stay and ask for a promotion');
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(2), 'learning fast and steady income');
    await settle(tester);
    await frame();

    await tester.tap(find.text('Send to Sharpen'));
    await settle(tester);
    await frame();

    await tester.tap(find.byTooltip('History'));
    await settle(tester);
    await frame();

    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    await tester.tap(find.text('Dark'));
    await settle(tester);
    await frame();

    await tester.tap(find.byTooltip('Templates'));
    await settle(tester);
    await frame();
  }, variant: windows, skip: !autoUpdateGoldenFiles); // only when recording
}
