import 'package:flutter/material.dart';

// The look is "frosted lilac": a soft lavender to pink background with glossy
// blobs behind it, see-through white cards on top and white pill buttons.
class AppColors {
  // Light mode
  static const lilac = Color(0xFFE6DDF3);
  static const blush = Color(0xFFF5DDEC);
  static const ink = Color(0xFF2B2533);
  static const inkSoft = Color(0xFF6F667A);
  static const plum = Color(0xFFB24E93);

  // Dark mode
  static const night = Color(0xFF1D1828);
  static const nightPink = Color(0xFF2E1B31);
  static const mist = Color(0xFFF3EDF7);
  static const mistSoft = Color(0xFFB4A9C0);
  static const pinkLight = Color(0xFFF29BCF);

  // The glossy shapes use the same colors in both modes.
  static const orbHighlight = Color(0xFFFFE6F3);
  static const orbPink = Color(0xFFF38BC3);
  static const orbMagenta = Color(0xFFD957AA);
  static const orbViolet = Color(0xFFB389EE);
}

// Colors that are not part of Material's ColorScheme, like the see-through
// card color. Screens read them with GlassColors.of(context).
class GlassColors {
  const GlassColors({
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.glass,
    required this.glassBorder,
    required this.bubble,
  });

  final Color backgroundTop;
  final Color backgroundBottom;
  final Color glass; // frosted cards
  final Color glassBorder;
  final Color bubble; // solid white cards and chat bubbles

  static const light = GlassColors(
    backgroundTop: AppColors.lilac,
    backgroundBottom: AppColors.blush,
    glass: Color(0x8CFFFFFF),
    glassBorder: Color(0xCCFFFFFF),
    bubble: Color(0xF2FFFFFF),
  );

  static const dark = GlassColors(
    backgroundTop: AppColors.night,
    backgroundBottom: AppColors.nightPink,
    glass: Color(0x17FFFFFF),
    glassBorder: Color(0x26FFFFFF),
    bubble: Color(0xFF2D2538),
  );

  static GlassColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}

ThemeData buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final glass = isDark ? GlassColors.dark : GlassColors.light;

  final text = isDark ? AppColors.mist : AppColors.ink;
  final textSoft = isDark ? AppColors.mistSoft : AppColors.inkSoft;
  final accent = isDark ? AppColors.pinkLight : AppColors.plum;

  final colors = ColorScheme(
    brightness: brightness,
    primary: accent,
    onPrimary: isDark ? AppColors.night : Colors.white,
    secondary: accent,
    onSecondary: isDark ? AppColors.night : Colors.white,
    error: isDark ? const Color(0xFFFF9DA8) : const Color(0xFFB3263A),
    onError: Colors.white,
    surface: glass.backgroundTop,
    onSurface: text,
    onSurfaceVariant: textSoft,
    surfaceContainerLow: glass.bubble,
    surfaceContainerHigh: glass.bubble,
    outline: glass.glassBorder,
  );

  // Every TextStyle made here needs the font family, because a style set on a
  // component replaces the theme's default font.
  TextStyle figtree(double size, FontWeight weight, Color color, {double height = 1.4}) {
    return TextStyle(
      fontFamily: 'Figtree',
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
    );
  }

  const pillShape = StadiumBorder();
  final sheetColor = isDark ? const Color(0xFF2A2234) : const Color(0xFFFBF7FD);

  return ThemeData(
    brightness: brightness,
    colorScheme: colors,
    fontFamily: 'Figtree',
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: TextTheme(
      displaySmall: figtree(46, FontWeight.w400, text, height: 1.0),
      headlineMedium: figtree(32, FontWeight.w400, text, height: 1.1),
      titleLarge: figtree(22, FontWeight.w500, text, height: 1.2),
      titleMedium: figtree(16, FontWeight.w600, text),
      bodyMedium: figtree(15, FontWeight.w400, text, height: 1.45),
      bodySmall: figtree(13, FontWeight.w400, textSoft),
      labelMedium: figtree(13, FontWeight.w500, textSoft),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: glass.glass,
      hintStyle: figtree(15, FontWeight.w400, textSoft),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: glass.glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: glass.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: accent, width: 1.2),
      ),
    ),
    // The main button is a white pill with dark text, like a soft key.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: glass.bubble,
        foregroundColor: text,
        disabledBackgroundColor: glass.glass,
        disabledForegroundColor: textSoft,
        minimumSize: const Size(0, 58),
        shape: pillShape,
        textStyle: figtree(16, FontWeight.w500, text),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: text,
        backgroundColor: glass.glass,
        side: BorderSide(color: glass.glassBorder),
        shape: pillShape,
        minimumSize: const Size(0, 46),
        textStyle: figtree(14, FontWeight.w500, text),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        textStyle: figtree(14, FontWeight.w600, accent),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        foregroundColor: textSoft,
        backgroundColor: glass.glass,
        selectedForegroundColor: text,
        selectedBackgroundColor: glass.bubble,
        side: BorderSide(color: glass.glassBorder),
        shape: pillShape,
        minimumSize: const Size(0, 46),
        textStyle: figtree(14, FontWeight.w500, text),
      ),
    ),
    chipTheme: ChipThemeData(
      side: BorderSide(color: glass.glassBorder),
      backgroundColor: glass.glass,
      selectedColor: glass.bubble,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      labelStyle: TextStyle(
        fontFamily: 'Figtree',
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        color: WidgetStateColor.resolveWith((states) {
          return states.contains(WidgetState.selected) ? text : textSoft;
        }),
      ),
      shape: pillShape,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: sheetColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: figtree(22, FontWeight.w500, text),
      contentTextStyle: figtree(14.5, FontWeight.w400, textSoft),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: sheetColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: text,
      contentTextStyle: figtree(14, FontWeight.w500, isDark ? AppColors.night : Colors.white),
      shape: pillShape,
    ),
    dividerTheme: DividerThemeData(color: glass.glassBorder, thickness: 1, space: 1),
  );
}
