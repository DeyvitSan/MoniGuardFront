// Material 3 | Urbanist + Playfair Display | StadiumBorder-first

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//Tokens color
abstract final class AppColors {
  //Primario — Marrón Cacao Profundo
  static const Color cacaoDark    = Color(0xFF3E2723);
  static const Color cacaoMid     = Color(0xFF6D4C41);
  static const Color cacaoLight   = Color(0xFFBCAAA4);

  //Secundario — Verde Bosque
  static const Color forestDeep   = Color(0xFF2E7D32);
  static const Color forestMid    = Color(0xFF388E3C);

  //Terciario — Esmeralda Suave
  static const Color emeraldSoft  = Color(0xFF81C784);
  static const Color emeraldPale  = Color(0xFFC8E6C9);

  //Neutrales Dark
  static const Color surfaceDark  = Color(0xFF121212);
  static const Color surface01    = Color(0xFF1E1E1E);
  static const Color surface02    = Color(0xFF252525);
  static const Color onSurfDark   = Color(0xFFE8E0D0);

  //Neutrales Light
  static const Color creamLight   = Color(0xFFFFF8E1);
  static const Color creamSurface = Color(0xFFFFF3CC);
  static const Color onSurfLight  = Color(0xFF1A120B);

  //Estado / Semánticos
  static const Color success      = Color(0xFF4CAF50);
  static const Color warning      = Color(0xFFFF8F00);
  static const Color error        = Color(0xFFB71C1C);
  static const Color info         = Color(0xFF0277BD);
}

//Tokens forma
abstract final class AppShapes {
  static const double radiusSm  = 12.0;
  static const double radiusMd  = 24.0;  //estándar componentes
  static const double radiusLg  = 32.0;
  static const double radiusXl  = 40.0;

  static final ShapeBorder stadium    = const StadiumBorder();
  static final ShapeBorder cardShape  = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radiusMd),
  );
  static final ShapeBorder chipShape  = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radiusSm),
  );
}

//Tipografia
abstract final class AppTypography {
  //Playfair Display → títulos de impacto editorial
  static TextStyle playfair({
    double size = 32,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  //Urbanist → cuerpo, etiquetas, UI en general
  static TextStyle urbanist({
    double size = 16,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.urbanist(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  //Escala tipográfica completa para TextTheme
  static TextTheme buildTextTheme(Color onColor) => TextTheme(
    // Playfair → Display / Headline
    displayLarge: playfair(size: 57, weight: FontWeight.w700, color: onColor, height: 1.12),
    displayMedium: playfair(size: 45, weight: FontWeight.w700, color: onColor, height: 1.16),
    displaySmall: playfair(size: 36, weight: FontWeight.w600, color: onColor, height: 1.22),
    headlineLarge: playfair(size: 32, weight: FontWeight.w700, color: onColor, height: 1.25),
    headlineMedium: playfair(size: 28, weight: FontWeight.w600, color: onColor, height: 1.29),
    headlineSmall: playfair(size: 24, weight: FontWeight.w600, color: onColor, height: 1.33),
    // Urbanist → Title / Body / Label
    titleLarge: urbanist(size: 22, weight: FontWeight.w600, color: onColor, height: 1.27),
    titleMedium: urbanist(size: 16, weight: FontWeight.w600, color: onColor, height: 1.5, letterSpacing: 0.15),
    titleSmall: urbanist(size: 14, weight: FontWeight.w600, color: onColor, height: 1.43, letterSpacing: 0.1),
    bodyLarge: urbanist(size: 16, weight: FontWeight.w400, color: onColor, height: 1.5, letterSpacing: 0.5),
    bodyMedium: urbanist(size: 14, weight: FontWeight.w400, color: onColor, height: 1.43, letterSpacing: 0.25),
    bodySmall: urbanist(size: 12, weight: FontWeight.w400, color: onColor, height: 1.33, letterSpacing: 0.4),
    labelLarge: urbanist(size: 14, weight: FontWeight.w700, color: onColor, height: 1.43, letterSpacing: 1.25),
    labelMedium: urbanist(size: 12, weight: FontWeight.w600, color: onColor, height: 1.33, letterSpacing: 1.5),
    labelSmall: urbanist(size: 11, weight: FontWeight.w600, color: onColor, height: 1.45, letterSpacing: 1.5),
  );
}

//Tema principal
abstract final class AppTheme {
  //ColorScheme LIGHT
  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    //Primary
    primary:          AppColors.cacaoDark,
    onPrimary:        AppColors.creamLight,
    primaryContainer: AppColors.cacaoLight,
    onPrimaryContainer: AppColors.onSurfLight,
    //Secondary
    secondary:          AppColors.forestDeep,
    onSecondary:        Colors.white,
    secondaryContainer: AppColors.emeraldPale,
    onSecondaryContainer: AppColors.onSurfLight,
    //Tertiary
    tertiary:          AppColors.emeraldSoft,
    onTertiary:        AppColors.onSurfLight,
    tertiaryContainer: AppColors.emeraldPale,
    onTertiaryContainer: AppColors.forestDeep,
    //Error
    error:          AppColors.error,
    onError:        Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    //Surface / Background
    surface:          AppColors.creamLight,
    onSurface:        AppColors.onSurfLight,
    surfaceContainerHighest: AppColors.creamSurface,
    onSurfaceVariant: AppColors.cacaoMid,
    outline:          AppColors.cacaoLight,
    outlineVariant:   AppColors.cacaoLight,
    shadow:           Colors.black,
    scrim:            Colors.black,
    inverseSurface:   AppColors.onSurfLight,
    onInverseSurface: AppColors.creamLight,
    inversePrimary:   AppColors.cacaoLight,
  );

  //ColorScheme DARK
  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    //Primary
    primary:          AppColors.cacaoLight,
    onPrimary:        AppColors.cacaoDark,
    primaryContainer: AppColors.cacaoMid,
    onPrimaryContainer: AppColors.creamLight,
    //Secondary
    secondary:          AppColors.emeraldSoft,
    onSecondary:        AppColors.forestDeep,
    secondaryContainer: AppColors.forestDeep,
    onSecondaryContainer: AppColors.emeraldPale,
    //Tertiary
    tertiary:          AppColors.emeraldPale,
    onTertiary:        AppColors.forestDeep,
    tertiaryContainer: AppColors.forestMid,
    onTertiaryContainer: AppColors.emeraldPale,
    //Error
    error:          Color(0xFFFFB4AB),
    onError:        Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    //Surface / Background
    surface:          AppColors.surfaceDark,
    onSurface:        AppColors.onSurfDark,
    surfaceContainerHighest: AppColors.surface02,
    onSurfaceVariant: AppColors.cacaoLight,
    outline:          AppColors.cacaoMid,
    outlineVariant:   AppColors.surface02,
    shadow:           Colors.black,
    scrim:            Colors.black,
    inverseSurface:   AppColors.onSurfDark,
    onInverseSurface: AppColors.surfaceDark,
    inversePrimary:   AppColors.cacaoDark,
  );

  //ThemeData LIGHT
  static ThemeData get light => _build(
    scheme: _lightScheme,
    textTheme: AppTypography.buildTextTheme(AppColors.onSurfLight),
  );

  //ThemeData DARK
  static ThemeData get dark => _build(
    scheme: _darkScheme,
    textTheme: AppTypography.buildTextTheme(AppColors.onSurfDark),
  );

  //Builder compartido
  static ThemeData _build({
    required ColorScheme scheme,
    required TextTheme textTheme,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,

      //AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: AppTypography.playfair(
          size: 22,
          weight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),

      //ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: AppTypography.urbanist(
            size: 16,
            weight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      //OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outline, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: AppTypography.urbanist(
            size: 16,
            weight: FontWeight.w600,
          ),
        ),
      ),

      //FilledButton
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.secondary,
          foregroundColor: scheme.onSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: AppTypography.urbanist(
            size: 16,
            weight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      //Card
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.radiusMd),
        ),
        margin: const EdgeInsets.all(8),
      ),

      //Chip
      chipTheme: ChipThemeData(
        backgroundColor: scheme.secondaryContainer,
        labelStyle: AppTypography.urbanist(
          size: 12,
          weight: FontWeight.w600,
          letterSpacing: 0.5,
          color: scheme.onSecondaryContainer,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.radiusSm),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      //InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShapes.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShapes.radiusMd),
          borderSide: BorderSide(color: scheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShapes.radiusMd),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        labelStyle: AppTypography.urbanist(
          size: 14,
          weight: FontWeight.w500,
          color: scheme.onSurfaceVariant,
        ),
        hintStyle: AppTypography.urbanist(
          size: 14,
          color: scheme.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),

      //SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: AppTypography.urbanist(
          size: 14,
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.radiusSm),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      //BottomNavigationBar / NavigationBar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          AppTypography.urbanist(size: 12, weight: FontWeight.w600),
        ),
      ),

      //Divider
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }
}