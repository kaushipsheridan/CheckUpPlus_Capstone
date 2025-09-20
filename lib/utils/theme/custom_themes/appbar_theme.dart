import 'package:flutter/material.dart';

class CustomAppBarTheme {
  CustomAppBarTheme._();

  static AppBarTheme lightAppBarTheme = AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor:  Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    actionsIconTheme: IconThemeData(
      color: Color.fromARGB(255, 26, 77, 140),
      size: 24,
    ),
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Color.fromARGB(255, 26, 77, 140),
    ),
    iconTheme: const IconThemeData(
      color: Color.fromARGB(255, 26, 77, 140),
      size: 24,
    ),
  );
}