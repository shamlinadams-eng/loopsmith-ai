import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color neonAccent;
  final Color neonSecondary;
  final Color neonTertiary;
  final Color glassBg;
  final Color glassBorder;
  final Color subtleText;
  final Color success;
  final Color warning;
  final Color cardBg;

  const AppColorsExtension({
    required this.neonAccent,
    required this.neonSecondary,
    required this.neonTertiary,
    required this.glassBg,
    required this.glassBorder,
    required this.subtleText,
    required this.success,
    required this.warning,
    required this.cardBg,
  });

  @override
  AppColorsExtension copyWith({
    Color? neonAccent,
    Color? neonSecondary,
    Color? neonTertiary,
    Color? glassBg,
    Color? glassBorder,
    Color? subtleText,
    Color? success,
    Color? warning,
    Color? cardBg,
  }) =>
      AppColorsExtension(
        neonAccent: neonAccent ?? this.neonAccent,
        neonSecondary: neonSecondary ?? this.neonSecondary,
        neonTertiary: neonTertiary ?? this.neonTertiary,
        glassBg: glassBg ?? this.glassBg,
        glassBorder: glassBorder ?? this.glassBorder,
        subtleText: subtleText ?? this.subtleText,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        cardBg: cardBg ?? this.cardBg,
      );

  @override
  AppColorsExtension lerp(covariant ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      neonAccent: Color.lerp(neonAccent, other.neonAccent, t)!,
      neonSecondary: Color.lerp(neonSecondary, other.neonSecondary, t)!,
      neonTertiary: Color.lerp(neonTertiary, other.neonTertiary, t)!,
      glassBg: Color.lerp(glassBg, other.glassBg, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      subtleText: Color.lerp(subtleText, other.subtleText, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusRound = 100.0;

  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;

  static const double buttonHeight = 52.0;
  static const double chipHeight = 36.0;

  static const double opacityDisabled = 0.38;
  static const double opacityHint = 0.5;
  static const double opacityGlass = 0.08;
  static const double opacityGlassBorder = 0.12;
  static const double opacityGlow = 0.3;

  static const double borderDefault = 1.0;
  static const double borderSelected = 1.5;

  static final ThemeData darkTheme = _buildTheme(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF00E5FF),
      brightness: Brightness.dark,
      surface: const Color(0xFF0A0A0F),
      onSurface: const Color(0xFFE8E8F0),
    ),
    appColors: const AppColorsExtension(
      neonAccent: Color(0xFF00E5FF),
      neonSecondary: Color(0xFFBF5AF2),
      neonTertiary: Color(0xFF30D158),
      glassBg: Color(0x14FFFFFF),
      glassBorder: Color(0x1FFFFFFF),
      subtleText: Color(0xFF6E6E80),
      success: Color(0xFF30D158),
      warning: Color(0xFFFFD60A),
      cardBg: Color(0xFF12121A),
    ),
  );

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required AppColorsExtension appColors,
  }) {
    final textTheme = _buildTextTheme(colorScheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: appColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: BorderSide(color: appColors.glassBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          backgroundColor: appColors.neonAccent,
          foregroundColor: colorScheme.surface,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          side: BorderSide(color: appColors.glassBorder),
          foregroundColor: colorScheme.onSurface,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: appColors.glassBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: appColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: appColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: appColors.neonAccent, width: borderSelected),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: 14),
        hintStyle: textTheme.bodyMedium?.copyWith(color: appColors.subtleText),
        labelStyle: textTheme.bodyMedium,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: appColors.glassBg,
        selectedColor: appColors.neonAccent.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          side: BorderSide(color: appColors.glassBorder),
        ),
        labelStyle: textTheme.labelMedium,
        showCheckmark: false,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF0A0A0F),
        selectedItemColor: appColors.neonAccent,
        unselectedItemColor: appColors.subtleText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: textTheme.labelSmall,
      ),
      dividerTheme: DividerThemeData(
        color: appColors.glassBorder,
        thickness: 1,
      ),
      extensions: [appColors],
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    final base = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
        letterSpacing: -0.5,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        letterSpacing: -0.3,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: colorScheme.onSurface.withOpacity(0.7),
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      labelMedium: base.labelMedium?.copyWith(
        color: colorScheme.onSurface.withOpacity(0.8),
      ),
      labelSmall: base.labelSmall?.copyWith(
        color: colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }
}
