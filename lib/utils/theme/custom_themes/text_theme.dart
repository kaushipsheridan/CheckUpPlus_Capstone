import 'package:flutter/material.dart';

class AppTextTheme {
  AppTextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(255, 26, 77, 140),
    ),
    headlineMedium: const TextStyle().copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: Color.fromARGB(255, 26, 77, 140),
    ),
    headlineSmall: const TextStyle().copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color.fromARGB(255, 26, 77, 140),
    ),

    titleLarge: const TextStyle().copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color.fromARGB(255, 26, 77, 140),
    ),
    titleMedium: const TextStyle().copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color.fromARGB(255, 26, 77, 140),
    ),
    titleSmall: const TextStyle().copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Color.fromARGB(255, 26, 77, 140),
    ),

    bodyLarge: const TextStyle().copyWith(
      fontSize: 14,
      color: Color.fromARGB(255, 26, 77, 140),
    ),
    bodyMedium: const TextStyle().copyWith(
      fontSize: 12,
      color: Color.fromARGB(255, 26, 77, 140),
    ),
    bodySmall: const TextStyle().copyWith(
      fontSize: 10,
      color: Color.fromARGB(255, 26, 77, 140),
    ),

    labelLarge: const TextStyle().copyWith(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Color.fromARGB(255, 26, 77, 140),
    ),
    labelMedium: const TextStyle().copyWith(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Color.fromARGB(255, 26, 77, 140),
    ),
  );
}