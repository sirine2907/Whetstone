import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/history_provider.dart';
import 'providers/nav_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/sharpen_provider.dart';
import 'screens/home_shell.dart';
import 'services/claude_service.dart';
import 'theme.dart';

void main() {
  runApp(const WhetstoneApp());
}

class WhetstoneApp extends StatelessWidget {
  const WhetstoneApp({super.key, this.claudeService});

  // Tests pass a fake service here so they never hit the real API.
  final ClaudeService? claudeService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => SharpenProvider(claudeService: claudeService)),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Whetstone',
            debugShowCheckedModeBanner: false,
            theme: buildTheme(Brightness.light),
            darkTheme: buildTheme(Brightness.dark),
            themeMode: settings.themeMode,
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}
