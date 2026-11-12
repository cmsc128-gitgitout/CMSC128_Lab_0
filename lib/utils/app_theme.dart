// Defines the app's visual theme, including its color scheme
// and component styles.

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // static const Color seed = Color(0xFF6750A4);
  static const Color primary = Color(0xFF015798);
  static const Color secondary = Color(0xFFBBDEFD);
  static const Color accent = Color(0xFFFFA500);
  static const Color background = Color(0xFFE8F5E9);

  static const Color navSelected = accent;
  static const Color navUnselected = Colors.black;

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary).copyWith(
          primary: primary,
          onPrimary: Colors.white,
          secondary: secondary,
          secondaryContainer: secondary,
          tertiary: accent,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 68,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          indicatorColor: Colors.transparent,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: 30,
              color: selected ? navSelected : navUnselected,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? navSelected : navUnselected,
            );
          }),
        ),
      );
}
