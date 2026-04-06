import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
}

class AppRadius {
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double full = 100.0;
}

extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

extension TextStyleExtensions on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withSize(double size) => copyWith(fontSize: size);
}

/// Color palette based on user requirements
class AppColors {
  // Primary palette
  static const Color gold = Color(0xFFf7c53e);
  static const Color goldMuted = Color(0xFFe6c959);
  static const Color olive = Color(0xFFbdba66);
  static const Color oliveDeep = Color(0xFF5d6c31);

  // Backgrounds
  static const Color background = Color(0xFF0c4f55);
  static const Color surface = Color(0xFF0e5a61);
  static const Color surfaceLight = Color(0xFF137178);

  // Dark greens for accents
  static const Color forestGreen = Color(0xFF224723);

  // Text & neutrals
  static const Color textPrimary = Color(0xFFe5eaea);
  static const Color textSecondary = Color(0xFF81a1a4);
  static const Color textMuted = Color(0xFF5d8a8e);

  // Status
  static const Color important = Color(0xFFf7c53e);
  static const Color success = Color(0xFFbdba66);
  static const Color error = Color(0xFFe57373);
}

ThemeData get appTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.gold,
    secondary: AppColors.olive,
    surface: AppColors.surface,
    error: AppColors.error,
    onPrimary: AppColors.background,
    onSecondary: AppColors.textPrimary,
    onSurface: AppColors.textPrimary,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.spaceGrotesk(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
  ),
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.surface,
    indicatorColor: AppColors.gold.withValues(alpha: 0.15),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.gold,
        );
      }
      return GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: AppColors.gold, size: 24);
      }
      return const IconThemeData(color: AppColors.textSecondary, size: 24);
    }),
  ),
  textTheme: _buildTextTheme(),
);

ThemeData get lightTheme => appTheme;
ThemeData get darkTheme => appTheme;

TextTheme _buildTextTheme() {
  return TextTheme(
    displayLarge: GoogleFonts.spaceGrotesk(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -1.5,
    ),
    displayMedium: GoogleFonts.spaceGrotesk(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -1,
    ),
    displaySmall: GoogleFonts.spaceGrotesk(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    headlineLarge: GoogleFonts.spaceGrotesk(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    headlineMedium: GoogleFonts.spaceGrotesk(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    headlineSmall: GoogleFonts.spaceGrotesk(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleLarge: GoogleFonts.spaceGrotesk(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleMedium: GoogleFonts.spaceGrotesk(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleSmall: GoogleFonts.spaceGrotesk(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    bodyLarge: GoogleFonts.spaceGrotesk(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.spaceGrotesk(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.spaceGrotesk(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.4,
    ),
    labelLarge: GoogleFonts.spaceGrotesk(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    labelMedium: GoogleFonts.spaceGrotesk(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
    labelSmall: GoogleFonts.spaceGrotesk(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.textMuted,
    ),
  );
}
