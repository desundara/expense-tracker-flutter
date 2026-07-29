import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Raw brand palette — the literal colours from the Figma design.
/// These stay the same in both themes; they're brand accents, not
/// text/background roles (those live in [AppSemanticColors] below).
class AppColors {
  static const darkAmethyst = Color(0xFF10002B);
  static const darkAmethyst2 = Color(0xFF240046);
  static const indigoInk = Color(0xFF3C096C);
  static const indigoVelvet = Color(0xFF5A189A);
  static const royalViolet = Color(0xFF7B2CBF);
  static const lavenderPurple = Color(0xFF9D4EDD);
  static const mauveMagic = Color(0xFFC77DFF);
  static const mauve = Color(0xFFE0AAFF);
  static const petalFrost = Color(0xFFFFD6FF);
  static const mauvePale = Color(0xFFE7C6FF);
  static const mauvePale2 = Color(0xFFC8B6FF);
  static const periwinkle = Color(0xFFB8C0FF);
  static const periwinkle2 = Color(0xFFBBD0FF);
}

/// Theme-dependent colour roles. Every screen reads text and
/// background colours from here (via `context.colors`) instead of
/// pulling raw [AppColors] values directly — that was the bug that
/// made captions hard to read: a dark palette tone (indigoVelvet)
/// was being used as *text* on an already-dark background.
///
/// The palette is actually designed for exactly this dark/light
/// split: the rich, saturated tones (indigoVelvet, royalViolet...)
/// read well as text on a LIGHT surface, and the pale pastel tones
/// (petalFrost, mauve, periwinkle...) read well as text on a DARK
/// surface. Dark mode and light mode below simply use each group
/// in its correct role.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color pageBackground;
  final Color cardBackground;
  final Color textPrimary;
  final Color textBody;
  final Color textMuted;
  final Color divider;
  final Color inputFill;
  final Color inputBorder;
  final Color positive;
  final Color negative;

  const AppSemanticColors({
    required this.pageBackground,
    required this.cardBackground,
    required this.textPrimary,
    required this.textBody,
    required this.textMuted,
    required this.divider,
    required this.inputFill,
    required this.inputBorder,
    required this.positive,
    required this.negative,
  });

  static const dark = AppSemanticColors(
    pageBackground: AppColors.darkAmethyst,
    cardBackground: AppColors.indigoInk,
    textPrimary: AppColors.petalFrost,
    textBody: AppColors.mauve,
    textMuted: AppColors.mauvePale2,
    divider: Color(0x14FFFFFF),
    inputFill: Color(0x0AFFFFFF),
    inputBorder: Color(0x14FFFFFF),
    positive: Color(0xFF7BE0B8),
    negative: Color(0xFFFF9D9D),
  );

  static const light = AppSemanticColors(
    pageBackground: Color(0xFFFAF7FE),
    cardBackground: Colors.white,
    textPrimary: AppColors.darkAmethyst2,
    textBody: AppColors.indigoInk,
    textMuted: AppColors.indigoVelvet,
    divider: Color(0x14000000),
    inputFill: Color(0x08000000),
    inputBorder: Color(0x1F000000),
    positive: Color(0xFF1B9C63),
    negative: Color(0xFFD64545),
  );

  @override
  AppSemanticColors copyWith({
    Color? pageBackground,
    Color? cardBackground,
    Color? textPrimary,
    Color? textBody,
    Color? textMuted,
    Color? divider,
    Color? inputFill,
    Color? inputBorder,
    Color? positive,
    Color? negative,
  }) {
    return AppSemanticColors(
      pageBackground: pageBackground ?? this.pageBackground,
      cardBackground: cardBackground ?? this.cardBackground,
      textPrimary: textPrimary ?? this.textPrimary,
      textBody: textBody ?? this.textBody,
      textMuted: textMuted ?? this.textMuted,
      divider: divider ?? this.divider,
      inputFill: inputFill ?? this.inputFill,
      inputBorder: inputBorder ?? this.inputBorder,
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textBody: Color.lerp(textBody, other.textBody, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
    );
  }
}

/// Convenience accessor: `context.colors.textMuted` instead of
/// `Theme.of(context).extension<AppSemanticColors>()!.textMuted`.
extension AppThemeContext on BuildContext {
  AppSemanticColors get colors => Theme.of(this).extension<AppSemanticColors>()!;
}

class AppTheme {
  static ThemeData get dark => _build(Brightness.dark, AppSemanticColors.dark);
  static ThemeData get light => _build(Brightness.light, AppSemanticColors.light);

  static ThemeData _build(Brightness brightness, AppSemanticColors colors) {
    final base = brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();

    return base.copyWith(
      brightness: brightness,
      scaffoldBackgroundColor: colors.pageBackground,
      primaryColor: AppColors.royalViolet,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.royalViolet,
        secondary: AppColors.mauveMagic,
        surface: colors.cardBackground,
      ),
      extensions: [colors],
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.fraunces(
          fontSize: 34,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
        ),
        headlineMedium: GoogleFonts.fraunces(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(color: colors.textBody),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.royalViolet,
          foregroundColor: AppColors.petalFrost,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputFill,
        labelStyle: TextStyle(color: colors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mauveMagic),
        ),
      ),
    );
  }
}