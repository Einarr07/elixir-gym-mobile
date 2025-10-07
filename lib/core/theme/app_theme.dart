import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

ThemeData appTheme(){
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primary,
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: AppColors.textPrimary, fontSize: 16)
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.black26,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    )
  );
}