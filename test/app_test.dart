import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whetstone/main.dart';
import 'package:whetstone/services/claude_service.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
  }
}

Future<void> openApp(
  WidgetTester tester, {
  Map<String, String> secure = const {},
  ClaudeService? claude,
}) async {
  tester.view.physicalSize = const Size(600, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  FlutterSecureStorage.setMockInitialValues(Map.of(secure));
  await tester.pumpWidget(WhetstoneApp(claudeService: claude));
  await settle(tester);
}

void main() {
  testWidgets('with no key, sharpening makes an offline draft and saves it', (tester) async {
    await openApp(tester);

    await tester.enterText(find.byType(TextField).first, 'explain recursion');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Sharpen'));
    await settle(tester);

    expect(find.textContaining('offline draft. Fill in'), findsOneWidget);
    expect(find.textContaining('a patient teacher'), findsOneWidget);

    await tester.tap(find.text('History'));
    await settle(tester);
    expect(find.text('explain recursion'), findsWidgets);
  });

  testWidgets('with a key, the Claude text appears', (tester) async {
    final client = MockClient.streaming((_, _) async {
      final data = jsonEncode({
        'type': 'content_block_delta',
        'index': 0,
        'delta': {'type': 'text_delta', 'text': 'Rewritten by the fake.'},
      });
      return http.StreamedResponse(Stream.value(utf8.encode('data: $data\n\n')), 200);
    });
    await openApp(
      tester,
      secure: {'claude_api_key': 'test-key'},
      claude: ClaudeService(client: client),
    );

    expect(find.text('Uses Claude with your API key.'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'explain recursion');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Sharpen'));
    await settle(tester);

    expect(find.text('Rewritten by the fake.'), findsOneWidget);
  });

  testWidgets('a failed request shows the error and an offline option', (tester) async {
    final client = MockClient.streaming((_, _) async {
      return http.StreamedResponse(Stream.value(utf8.encode('{}')), 401);
    });
    await openApp(
      tester,
      secure: {'claude_api_key': 'bad-key'},
      claude: ClaudeService(client: client),
    );

    await tester.enterText(find.byType(TextField).first, 'explain recursion');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Sharpen'));
    await settle(tester);

    expect(find.textContaining('did not accept this API key'), findsOneWidget);

    await tester.tap(find.text('Use an offline draft instead'));
    await settle(tester);
    expect(find.textContaining('did not accept'), findsNothing);
    expect(find.textContaining('a patient teacher'), findsOneWidget);
  });

  testWidgets('a template fills in and goes to the Sharpen tab', (tester) async {
    await openApp(tester);

    await tester.tap(find.text('Templates'));
    await settle(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Study'));
    await settle(tester);
    expect(find.text('Cold Outreach Email'), findsNothing);

    await tester.tap(find.text('Teach Me a Concept'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, 'database indexes');
    await tester.pump();
    await tester.tap(find.text('Send to Sharpen'));
    await settle(tester);

    expect(find.textContaining('Teach me database indexes.'), findsOneWidget);
  });

  testWidgets('the dark setting changes the theme and is remembered', (tester) async {
    await openApp(tester);

    await tester.tap(find.text('Settings'));
    await settle(tester);
    await tester.tap(find.text('Dark'));
    await settle(tester);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'dark');
  });
}
