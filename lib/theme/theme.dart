import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Create a reactive variable for theme mode
Rx<ThemeMode> themeMode = ThemeMode.system.obs; // Using .obs to make it reactive

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color.fromARGB(255, 3, 184, 157),
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFF6EAEE7),
  onSecondary: Color(0xFFFFFFFF),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  background: Color(0xFFFCFDF6),
  onBackground: Color(0xFF1A1C18),
  shadow: Color(0xFF000000),
  outlineVariant: Color(0xFFC2C8BC),
  surface: Color(0xFFF9FAF3),
  onSurface: Color(0xFF1A1C18),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF416FDF),
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFF6EAEE7),
  onSecondary: Color(0xFFFFFFFF),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  background: Color(0xFFFCFDF6),
  onBackground: Color(0xFF1A1C18),
  shadow: Color(0xFF000000),
  outlineVariant: Color(0xFFC2C8BC),
  surface: Color(0xFFF9FAF3),
  onSurface: Color(0xFF1A1C18),
);

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: lightColorScheme,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(
        lightColorScheme.primary, // Slightly darker shade for the button
      ),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Text color
      elevation: MaterialStateProperty.all<double>(5.0), // Shadow
      padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(horizontal: 20, vertical: 18)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Adjust as needed
        ),
      ),
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
    displayLarge: TextStyle(color: Colors.black),
    displayMedium: TextStyle(color: Colors.black),
    // Add other text styles as needed
  ),
);

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: darkColorScheme,
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    displayLarge: TextStyle(color: Colors.white),
    displayMedium: TextStyle(color: Colors.white),
    // Add other text styles as needed
  ),
);