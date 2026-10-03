import 'package:flutter/material.dart';

class AppTheme {
  static const _blue = Color(0xFF1565C0);
  static const _blueDark = Color(0xFF9FC3FF);

  static ThemeData get lightTheme => _build(
    const ColorScheme.light(
      primary: _blue,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFD6E4FF),
      onPrimaryContainer: Color(0xFF001B3E),
      secondary: Color(0xFF4F6075),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD9E3F8),
      onSecondaryContainer: Color(0xFF0D1B2A),
      tertiary: Color(0xFF006874),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFB4EBF2),
      onTertiaryContainer: Color(0xFF001F24),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: Color(0xFFF9FBFF),
      onSurface: Color(0xFF191C20),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Color(0xFFF1F4F9),
      surfaceContainer: Color(0xFFECEFF4),
      surfaceContainerHigh: Color(0xFFE2E7EF),
      surfaceContainerHighest: Color(0xFFDCE2EA),
      onSurfaceVariant: Color(0xFF42474E),
      outline: Color(0xFF73777F),
      outlineVariant: Color(0xFFC3C8D0),
      inverseSurface: Color(0xFF2E3035),
      onInverseSurface: Color(0xFFF0F2F6),
      inversePrimary: Color(0xFFAAC7FF),
    ),
  );

  static ThemeData get darkTheme => _build(
    const ColorScheme.dark(
      primary: _blueDark,
      onPrimary: Color(0xFF00315F),
      primaryContainer: Color(0xFF004A99),
      onPrimaryContainer: Color(0xFFD6E4FF),
      secondary: Color(0xFFBAC8DD),
      onSecondary: Color(0xFF253144),
      secondaryContainer: Color(0xFF3B4A60),
      onSecondaryContainer: Color(0xFFD9E3F8),
      tertiary: Color(0xFF86D2DC),
      onTertiary: Color(0xFF00363D),
      tertiaryContainer: Color(0xFF004F58),
      onTertiaryContainer: Color(0xFFB4EBF2),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF101318),
      onSurface: Color(0xFFE2E7EF),
      surfaceContainerLowest: Color(0xFF0B0D11),
      surfaceContainerLow: Color(0xFF171A20),
      surfaceContainer: Color(0xFF1C2027),
      surfaceContainerHigh: Color(0xFF262B33),
      surfaceContainerHighest: Color(0xFF303640),
      onSurfaceVariant: Color(0xFFC3C8D0),
      outline: Color(0xFF8D929B),
      outlineVariant: Color(0xFF444A54),
      inverseSurface: Color(0xFFE2E7EF),
      onInverseSurface: Color(0xFF30343B),
      inversePrimary: _blue,
    ),
  );

  static ThemeData _build(ColorScheme scheme) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
    );
    return base.copyWith(
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 50),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 50),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        modalBackgroundColor: scheme.surfaceContainerLow,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
      ),
    );
  }
}
