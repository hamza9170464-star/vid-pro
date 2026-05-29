enum ThemeOption {
  darkRed,
  amoledBlack,
  blueNeon,
  greenMatrix,
  purpleGradient,
  lightMode;

  String get displayName {
    switch (this) {
      case ThemeOption.darkRed:
        return 'Dark Red';
      case ThemeOption.amoledBlack:
        return 'AMOLED Black';
      case ThemeOption.blueNeon:
        return 'Blue Neon';
      case ThemeOption.greenMatrix:
        return 'Green Matrix';
      case ThemeOption.purpleGradient:
        return 'Purple Gradient';
      case ThemeOption.lightMode:
        return 'Light Mode';
    }
  }

  bool get isDark => this != ThemeOption.lightMode;
}
