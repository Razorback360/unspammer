import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

/// Color palette constrained to the approved brand colors.
class AppColors {
  // Approved base colors.
  static const Color green = Color(0xFF00573F);
  static const Color gold = Color(0xFFDAC961);
  static const Color navy = Color(0xFF003E51);
  static const Color white = Color(0xFFFFFFFF);

  // Theme state
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.system);
  
  static bool get isDark {
    final mode = themeModeNotifier.value;
    if (mode == ThemeMode.system) {
      return SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return mode == ThemeMode.dark;
  }
  
  static void toggleTheme() {
    themeModeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
  }

  // Derived semantic tokens using only the approved colors (with alpha when needed).
  static Color get goldMuted => gold;
  static Color get olive => green;
  static Color get oliveDeep => green;
  static Color get forestGreen => green;

  static Color get background => isDark ? const Color(0xFF0D181D) : const Color(0xFFF7F8F9); // Very dark navy for dark bg
  static Color get surface => isDark ? const Color(0xFF14242B) : white;
  static Color get surfaceLight => isDark ? const Color(0xFF1B313A) : white;

  static Color get textPrimary => isDark ? white : navy;
  static Color get textSecondary => isDark ? white.withValues(alpha: 0.7) : navy.withValues(alpha: 0.6);
  static Color get textMuted => isDark ? white.withValues(alpha: 0.4) : navy.withValues(alpha: 0.4);

  static Color get important => gold;
  static Color get success => green;
  static Color get error => gold;

  static Color get primary => green;
  static Color get secondary => isDark ? white : navy;
  static Color get accent => gold;
  static Color get accentStrong => gold;

  static Color get border => isDark ? white.withValues(alpha: 0.1) : navy.withValues(alpha: 0.1);
  static Color get hover => isDark ? white.withValues(alpha: 0.05) : navy.withValues(alpha: 0.05);
  static Color get pressed => gold.withValues(alpha: 0.1);
  static Color get disabled => isDark ? white.withValues(alpha: 0.2) : navy.withValues(alpha: 0.2);

  // Compatibility aliases
  static Color get emerald => green;
  static Color get mist => white;
  static Color get graphite => textMuted;
  static Color get pine => green;
  static Color get amber => gold;
}

ThemeData get appTheme => ThemeData(
  useMaterial3: true,
  brightness: AppColors.isDark ? Brightness.dark : Brightness.light,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: (AppColors.isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
    error: AppColors.error,
    onPrimary: AppColors.white,
    onSecondary: AppColors.white,
    onSurface: AppColors.textPrimary,
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: AppColors.surface,
    headerBackgroundColor: AppColors.primary,
    headerForegroundColor: AppColors.white,
    dayStyle: GoogleFonts.spaceGrotesk(),
    weekdayStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
    yearStyle: GoogleFonts.spaceGrotesk(),
    todayForegroundColor: WidgetStateProperty.all(AppColors.accent),
    todayBorder: BorderSide(color: AppColors.accent),
    dayForegroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.surface;
      if (states.contains(WidgetState.disabled)) return AppColors.textMuted;
      return AppColors.textPrimary;
    }),
    dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primary;
      return null;
    }),
    cancelButtonStyle: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
    confirmButtonStyle: TextButton.styleFrom(foregroundColor: AppColors.primary),
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: AppColors.surface,
    dayPeriodTextStyle: GoogleFonts.spaceGrotesk(),
    helpTextStyle: GoogleFonts.spaceGrotesk(color: AppColors.textSecondary),
    dialBackgroundColor: AppColors.isDark ? AppColors.surfaceLight : AppColors.surfaceLight.withValues(alpha: 0.5),
    dialTextColor: AppColors.textPrimary,
    dialHandColor: AppColors.primary,
    entryModeIconColor: AppColors.primary,
    hourMinuteTextStyle: GoogleFonts.spaceGrotesk(fontSize: 48, fontWeight: FontWeight.bold),
    hourMinuteColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primary.withValues(alpha: 0.2);
      return AppColors.surfaceLight;
    }),
    hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primary;
      return AppColors.textPrimary;
    }),
    dayPeriodColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primary.withValues(alpha: 0.2);
      return AppColors.surfaceLight;
    }),
    dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primary;
      return AppColors.textPrimary;
    }),
    cancelButtonStyle: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
    confirmButtonStyle: TextButton.styleFrom(foregroundColor: AppColors.primary),
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
    indicatorColor: AppColors.accent.withValues(alpha: 0.15),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        );
      }
      return GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary.withValues(alpha: 0.7),
      );
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return IconThemeData(color: AppColors.accent, size: 24);
      }
      return IconThemeData(
        color: AppColors.textSecondary.withValues(alpha: 0.7),
        size: 24,
      );
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
