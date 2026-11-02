import 'package:flutter/material.dart';

// The look is "stone and paper": warm off-white in light mode, dark stone in
// dark mode, with one ember color for the things you can press.
class AppColors {
  static const paper = Color(0xFFF6F1E7);
  static const paperCard = Color(0xFFFFFBF3);
  static const ink = Color(0xFF26221C);
  static const inkSoft = Color(0xFF6A6256);
  static const paperLine = Color(0xFFE2D9C8);
  static const ember = Color(0xFFB5482A);
  static const moss = Color(0xFF4F6339);

  static const stone = Color(0xFF1B1916);
  static const stoneCard = Color(0xFF26231F);
  static const chalk = Color(0xFFF0EADD);
  static const chalkSoft = Color(0xFFA89F90);
  static const stoneLine = Color(0xFF3A362F);
  static const emberLight = Color(0xFFEC8258);
  static const mossLight = Color(0xFF9DB57F);
}

ThemeData buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  final background = isDark ? AppColors.stone : AppColors.paper;
  final card = isDark ? AppColors.stoneCard : AppColors.paperCard;
  final text = isDark ? AppColors.chalk : AppColors.ink;
  final textSoft = isDark ? AppColors.chalkSoft : AppColors.inkSoft;
  final line = isDark ? AppColors.stoneLine : AppColors.paperLine;
  final accent = isDark ? AppColors.emberLight : AppColors.ember;
  final secondary = isDark ? AppColors.mossLight : AppColors.moss;

  final colors = ColorScheme(
    brightness: brightness,
    primary: accent,
    onPrimary: isDark ? AppColors.stone : Colors.white,
    secondary: secondary,
    onSecondary: isDark ? AppColors.stone : Colors.white,
    error: isDark ? const Color(0xFFF2A08F) : const Color(0xFFA32B1C),
    onError: isDark ? AppColors.stone : Colors.white,
    surface: background,
    onSurface: text,
    onSurfaceVariant: textSoft,
    surfaceContainerLow: card,
    outline: line,
  );

  // Fraunces is a variable font, so the weight is set with a font variation.
  TextStyle serif(double size) => TextStyle(
    fontFamily: 'Fraunces',
    fontSize: size,
    height: 1.15,
    color: text,
    fontVariations: const [FontVariation('wght', 560)],
  );

  return ThemeData(
    brightness: brightness,
    colorScheme: colors,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: background,
    textTheme: TextTheme(
      headlineMedium: serif(30),
      titleLarge: serif(21),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: text),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: text),
      bodySmall: TextStyle(fontSize: 12.5, height: 1.4, color: textSoft),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSoft),
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      hintStyle: TextStyle(color: textSoft),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accent, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: text,
        side: BorderSide(color: line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    chipTheme: ChipThemeData(
      side: BorderSide(color: line),
      backgroundColor: card,
      labelStyle: TextStyle(fontSize: 13, color: text),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: card,
      indicatorColor: accent.withValues(alpha: 0.18),
      surfaceTintColor: Colors.transparent,
      height: 66,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: text),
      ),
    ),
    dividerTheme: DividerThemeData(color: line, thickness: 1, space: 1),
  );
}
