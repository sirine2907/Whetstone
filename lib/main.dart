import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/history_provider.dart';
import 'providers/nav_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/sharpen_provider.dart';
import 'screens/home_shell.dart';
import 'screens/welcome_screen.dart';
import 'services/claude_service.dart';
import 'theme.dart';
import 'widgets/glass.dart';

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
          // Until the settings are read we don't know which screen to show,
          // so just the background is drawn for that moment.
          Widget home = const GlowBackground(child: SizedBox());
          if (settings.loaded) {
            home = settings.seenWelcome ? const HomeShell() : const WelcomeScreen();
          }

          return MaterialApp(
            title: 'Whetstone',
            debugShowCheckedModeBanner: false,
            theme: buildTheme(Brightness.light),
            darkTheme: buildTheme(Brightness.dark),
            themeMode: settings.themeMode,
            home: home,
          );
        },
      ),
    );
  }
}
