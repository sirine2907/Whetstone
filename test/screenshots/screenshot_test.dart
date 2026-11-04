// Renders the app into docs/screenshots for the README.
// Run: flutter test test/screenshots --update-goldens
@Tags(['screenshots'])
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whetstone/main.dart';
import 'package:whetstone/models/sharpened_prompt.dart';

// Without loading a real font the test renders every letter as a box.
Future<void> loadFonts() async {
  final figtree = FontLoader('Figtree');
  for (final weight in ['Light', 'Regular', 'Medium', 'SemiBold']) {
    figtree.addFont(rootBundle.load('assets/fonts/Figtree-$weight.ttf'));
  }
  final icons = FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await Future.wait([figtree.load(), icons.load()]);
}

String savedPrompt(String id, String original, SharpenFocus focus, {bool starred = false}) {
  return jsonEncode(
    SharpenedPrompt(
      id: id,
      original: original,
      sharpened: 'You are an expert.\n\n$original.',
      focus: focus,
      usedClaude: false,
      createdAt: DateTime(2026, 11, 2),
      starred: starred,
    ).toJson(),
  );
}

final seededHistory = [
  savedPrompt('1', 'help me write an email asking for a raise', SharpenFocus.clear, starred: true),
  savedPrompt('2', 'explain recursion', SharpenFocus.detailed),
  savedPrompt('3', 'fix my flutter app crashing on startup', SharpenFocus.structured),
  savedPrompt('4', 'plan a one week launch for my side project', SharpenFocus.structured, starred: true),
];

Future<void> openApp(
  WidgetTester tester, {
  bool darkMode = false,
  double height = 915,
  bool seenWelcome = true,
}) async {
  tester.view.physicalSize = Size(412, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({
    'history': seededHistory,
    'theme_mode': darkMode ? 'dark' : 'light',
    'seen_welcome': seenWelcome,
  });
  FlutterSecureStorage.setMockInitialValues({});

  await tester.pumpWidget(const WhetstoneApp());
  await settle(tester);
}

// shared_preferences answers outside the fake clock, so give it real time.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
  }
}

Future<void> sharpenExample(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).first, 'explain recursion');
  await tester.pump();
  await tester.tap(find.text('Structured').first);
  await settle(tester);
  await tester.tap(find.widgetWithText(FilledButton, 'Sharpen'));
  await settle(tester);
}

// A bit taller than a phone so the input and the whole result fit in one image.
const resultHeight = 1020.0;

Future<void> takeScreenshot(String name) async {
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../docs/screenshots/$name.png'),
  );
}

final windows = TargetPlatformVariant.only(TargetPlatform.windows);

void main() {
  setUpAll(loadFonts);

  testWidgets('welcome screen', (tester) async {
    await openApp(tester, seenWelcome: false);
    await takeScreenshot('01_welcome');
  }, variant: windows);

  testWidgets('home screen', (tester) async {
    await openApp(tester);
    await takeScreenshot('02_home');
  }, variant: windows);

  testWidgets('sharpened result', (tester) async {
    await openApp(tester, height: resultHeight);
    await sharpenExample(tester);
    await takeScreenshot('03_result');
  }, variant: windows);

  testWidgets('templates screen', (tester) async {
    await openApp(tester);
    await tester.tap(find.byTooltip('Templates'));
    await settle(tester);
    await takeScreenshot('04_templates');
  }, variant: windows);

  testWidgets('template detail', (tester) async {
    await openApp(tester);
    await tester.tap(find.byTooltip('Templates'));
    await settle(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Work'));
    await settle(tester);
    await tester.tap(find.text('Weigh Two Options'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).at(0), 'take the remote job');
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(1), 'stay and ask for a promotion');
    await settle(tester);
    await takeScreenshot('05_template_detail');
  }, variant: windows);

  testWidgets('history screen', (tester) async {
    await openApp(tester);
    await tester.tap(find.byTooltip('History'));
    await settle(tester);
    await takeScreenshot('06_history');
  }, variant: windows);

  testWidgets('settings screen', (tester) async {
    await openApp(tester);
    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    await takeScreenshot('07_settings');
  }, variant: windows);

  testWidgets('dark home', (tester) async {
    await openApp(tester, darkMode: true);
    await takeScreenshot('08_dark_home');
  }, variant: windows);

  testWidgets('dark result', (tester) async {
    await openApp(tester, darkMode: true, height: resultHeight);
    await sharpenExample(tester);
    await takeScreenshot('09_dark_result');
  }, variant: windows);
}
