import 'package:checkupplus_capstone/utils/theme/custom_themes/appbar_theme.dart';
import 'package:checkupplus_capstone/utils/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:checkupplus_capstone/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:checkupplus_capstone/utils/theme/custom_themes/text_theme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: 'Poppins',
    primarySwatch: Colors.blue,
    primaryColor: const Color.fromARGB(255, 52, 139, 203),
    scaffoldBackgroundColor: Colors.white,
    textTheme: AppTextTheme.lightTextTheme,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 26, 77, 140)),
    elevatedButtonTheme: AppElevatedButtonThemeData.lightElevatedButtonTheme,
    appBarTheme: CustomAppBarTheme.lightAppBarTheme,
    bottomSheetTheme: AppBottomSheetTheme.lightBottomSheetTheme,
  );
}