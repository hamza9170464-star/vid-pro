import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_option.dart';

class AppTheme {
  // Theme Color Configurations
  static const Color darkRedPrimary = Color(0xFFE50914);
  static const Color darkRedBackground = Color(0xFF0E0E10);
  static const Color darkRedSurface = Color(0xFF18181B);

  static const Color amoledPrimary = Color(0xFFFF2E2E);
  static const Color amoledBackground = Color(0xFF000000);
  static const Color amoledSurface = Color(0xFF0D0D0D);

  static const Color blueNeonPrimary = Color(0xFF00F0FF);
  static const Color blueNeonBackground = Color(0xFF080E1C);
  static const Color blueNeonSurface = Color(0xFF10182E);

  static const Color greenMatrixPrimary = Color(0xFF00FF41);
  static const Color greenMatrixBackground = Color(0xFF030704);
  static const Color greenMatrixSurface = Color(0xFF0C140D);

  static const Color purpleGradientPrimary = Color(0xFFF72585);
  static const Color purpleGradientBackground = Color(0xFF110724);
  static const Color purpleGradientSurface = Color(0xFF1B0D33);

  static const Color lightPrimary = Color(0xFF6C63FF);
  static const Color lightBackground = Color(0xFFF5F6FA);
  static const Color lightSurface = Color(0xFFFFFFFF);

  // Retrieve standard ThemeData mapping based on selection
  static ThemeData getTheme(ThemeOption option) {
    final isDark = option.isDark;
    final colorScheme = _getColorScheme(option);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      cardColor: colorScheme.surfaceVariant,
      
      // Custom Typography utilizing Outfit font
      textTheme: GoogleFonts.outfitTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).apply(
        bodyColor: colorScheme.onBackground,
        displayColor: colorScheme.onBackground,
      ),

      // App Bar styling
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
        ),
        iconTheme: IconThemeData(color: colorScheme.onBackground),
      ),

      // Bottom Navigation styling
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.background,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onBackground.withOpacity(0.5),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12),
      ),

      // Navigation Rail styling
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.background,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: IconThemeData(color: colorScheme.onBackground.withOpacity(0.5)),
      ),

      // Input Decoration (Text fields) styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        labelStyle: GoogleFonts.outfit(),
        hintStyle: GoogleFonts.outfit(color: colorScheme.onBackground.withOpacity(0.4)),
      ),

      // Buttons styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      // Card styling
      cardTheme: CardTheme(
        color: colorScheme.surfaceVariant,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Dialog styling
      dialogTheme: DialogTheme(
        backgroundColor: colorScheme.surface,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      // Bottom Sheet styling
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 10,
        modalBackgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  // Construct color scheme mapping for different themes
  static ColorScheme _getColorScheme(ThemeOption option) {
    switch (option) {
      case ThemeOption.darkRed:
        return const ColorScheme.dark(
          primary: darkRedPrimary,
          secondary: Color(0xFFB8070F),
          background: darkRedBackground,
          surface: darkRedSurface,
          surfaceVariant: Color(0xFF27272A),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: Colors.white,
          onSurface: Colors.white,
          error: Colors.redAccent,
        );
      case ThemeOption.amoledBlack:
        return const ColorScheme.dark(
          primary: amoledPrimary,
          secondary: Color(0xFFFF5252),
          background: amoledBackground,
          surface: amoledSurface,
          surfaceVariant: Color(0xFF141414),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: Colors.white,
          onSurface: Colors.white,
          error: Colors.redAccent,
        );
      case ThemeOption.blueNeon:
        return const ColorScheme.dark(
          primary: blueNeonPrimary,
          secondary: Color(0xFF0072FF),
          background: blueNeonBackground,
          surface: blueNeonSurface,
          surfaceVariant: Color(0xFF16223F),
          onPrimary: Color(0xFF03070C),
          onSecondary: Colors.white,
          onBackground: Color(0xFFE2F1FF),
          onSurface: Color(0xFFE2F1FF),
          error: Colors.redAccent,
        );
      case ThemeOption.greenMatrix:
        return const ColorScheme.dark(
          primary: greenMatrixPrimary,
          secondary: Color(0xFF00A325),
          background: greenMatrixBackground,
          surface: greenMatrixSurface,
          surfaceVariant: Color(0xFF142416),
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onBackground: Color(0xFFD0FFD6),
          onSurface: Color(0xFFD0FFD6),
          error: Colors.redAccent,
        );
      case ThemeOption.purpleGradient:
        return const ColorScheme.dark(
          primary: purpleGradientPrimary,
          secondary: Color(0xFF7209B7),
          background: purpleGradientBackground,
          surface: purpleGradientSurface,
          surfaceVariant: Color(0xFF29154A),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: Color(0xFFF4EFFF),
          onSurface: Color(0xFFF4EFFF),
          error: Colors.pinkAccent,
        );
      case ThemeOption.lightMode:
        return const ColorScheme.light(
          primary: lightPrimary,
          secondary: Color(0xFF8F87FF),
          background: lightBackground,
          surface: lightSurface,
          surfaceVariant: Color(0xFFE8EBF2),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: Color(0xFF1E1F22),
          onSurface: Color(0xFF1E1F22),
          error: Colors.red,
        );
    }
  }

  // Gradient Helper matching the selected theme (Vibrant glassmorphic effects)
  static List<Color> getGradientColors(ThemeOption option) {
    switch (option) {
      case ThemeOption.darkRed:
        return [darkRedPrimary, const Color(0xFF680408)];
      case ThemeOption.amoledBlack:
        return [amoledPrimary, const Color(0xFF800000)];
      case ThemeOption.blueNeon:
        return [blueNeonPrimary, const Color(0xFF0044FF)];
      case ThemeOption.greenMatrix:
        return [greenMatrixPrimary, const Color(0xFF003B00)];
      case ThemeOption.purpleGradient:
        return [purpleGradientPrimary, const Color(0xFF4CC9F0)];
      case ThemeOption.lightMode:
        return [lightPrimary, const Color(0xFF3F37C9)];
    }
  }

  // Premium glow effect matching specific theme choices
  static BoxShadow getGlow(ThemeOption option) {
    final colors = getGradientColors(option);
    return BoxShadow(
      color: colors.first.withOpacity(0.3),
      blurRadius: 16,
      spreadRadius: 2,
    );
  }
}
