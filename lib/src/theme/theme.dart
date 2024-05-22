import 'package:flutter/material.dart';

ThemeData themeData = ThemeData(
  fontFamily: 'Roboto',
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0C5B35)),
  scaffoldBackgroundColor: ColorConstants.background,
  appBarTheme: const AppBarTheme(
      backgroundColor: ColorConstants.background,
      surfaceTintColor: ColorConstants.background,
      iconTheme: IconThemeData(
        size: 20,
        color: ColorConstants.grey03,
      ),
      titleTextStyle: TextStyle(
        fontFamily: 'roboto',
        fontWeight: FontWeight.w500,
        fontSize: 20,
        height: 23.44 / 20,
        color: ColorConstants.grey03,
      )),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
    ),
  ),
  useMaterial3: true,
);

class ColorConstants {
  static const main01 = Color(0xFFC2EED5);
  static const grey02 = Color(0xFF333333);
  static const grey03 = Color(0xFF4D4D4D);
  static const grey04 = Color(0xFF666666);
  static const grey09 = Color(0xFFE6E6E6);
  static const white = Color(0xFFFFFFFF);
  static const background = Color(0xFFF5F5F5);
}

TextTheme textTheme = const TextTheme(
    headlineMedium: TextStyle(
      fontFamily: 'roboto',
      fontWeight: FontWeight.w500,
      fontSize: 20,
      height: 23.44 / 20,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'roboto',
      fontWeight: FontWeight.w500,
      fontSize: 16,
      height: 18.75 / 16,
    ),
    bodyMedium: TextStyle(
        fontFamily: 'roboto',
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 16.41 / 14),
    labelMedium: TextStyle(
      fontFamily: 'roboto',
      fontWeight: FontWeight.w400,
      fontSize: 12,
      height: 14.06 / 12,
    ),
    labelSmall: TextStyle(
        fontFamily: 'roboto',
        fontWeight: FontWeight.w400,
        fontSize: 10,
        height: 11.72 / 10));
