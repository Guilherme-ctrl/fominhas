import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Core Colors
  static const Color primaryColor = Color(0xFF00D4AA);      // Teal accent
  static const Color primaryDark = Color(0xFF00B894);       // Darker teal
  static const Color secondaryColor = Color(0xFF6C5CE7);    // Purple accent
  
  // Background Colors
  static const Color backgroundDark = Color(0xFF0D1117);    // Very dark blue-gray
  static const Color surfaceDark = Color(0xFF161B22);       // Dark surface
  static const Color cardDark = Color(0xFF21262D);          // Card background
  
  // Text Colors
  static const Color textPrimary = Color(0xFFE6EDF3);       // Primary text
  static const Color textSecondary = Color(0xFF8B949E);     // Secondary text
  static const Color textTertiary = Color(0xFF656D76);      // Tertiary text
  
  // Status Colors
  static const Color successColor = Color(0xFF2EA043);      // Green
  static const Color warningColor = Color(0xFFD29922);      // Orange
  static const Color errorColor = Color(0xFFDA3633);        // Red
  static const Color infoColor = Color(0xFF1F6FEB);         // Blue
  
  // Sport Specific Colors
  static const Color homeTeamColor = Color(0xFF1F6FEB);     // Blue for home team
  static const Color awayTeamColor = Color(0xFFDA3633);     // Red for away team
  static const Color goalColor = Color(0xFF2EA043);         // Green for goals
  static const Color assistColor = Color(0xFFD29922);       // Orange for assists

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        primaryContainer: primaryDark,
        secondary: secondaryColor,
        secondaryContainer: secondaryColor.withValues(alpha: 0.3),
        surface: surfaceDark,
        surfaceContainerHighest: cardDark,
        // background: backgroundDark, // deprecated - using surface instead
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        // onBackground: textPrimary, // deprecated - using onSurface instead
        error: errorColor,
        onError: Colors.white,
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: cardDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          elevation: 2,
          shadowColor: primaryColor.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textTertiary.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textTertiary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textTertiary),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardDark,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceDark,
        selectedColor: primaryColor.withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: textPrimary),
        secondaryLabelStyle: const TextStyle(color: textPrimary),
        side: BorderSide(color: textTertiary.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: textSecondary,
          fontSize: 16,
        ),
      ),
      
      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardDark,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        // Headlines
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        
        // Titles
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        
        // Body
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        
        // Labels
        labelLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          color: textTertiary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: textTertiary.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),
      
      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        textColor: textPrimary,
        iconColor: textSecondary,
        tileColor: Colors.transparent,
        selectedTileColor: primaryColor,
        selectedColor: Colors.black,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
  
  // Custom Gradient for special elements
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [cardDark, surfaceDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// Extension for theme shortcuts
extension ThemeExtension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}