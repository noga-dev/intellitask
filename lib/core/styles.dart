import 'package:flutter/material.dart';
import 'package:intellitask/gen/fonts.gen.dart';

final appThemeDark = ThemeData.dark(useMaterial3: true).copyWith(
  scaffoldBackgroundColor: AppColors.scaffoldBackgroundColorDark,
  cardTheme: _cardTheme,
  textTheme: _textTheme.copyWith(
    bodyMedium: _textStyle.copyWith(
      color: AppColors.textColorDark,
    ),
  ),
  progressIndicatorTheme: _progressIndicatorTheme,
  inputDecorationTheme: _inputDecorationTheme,
  floatingActionButtonTheme: _floatingActionButtonTheme,
  colorScheme: _colorScheme,
);

final appThemeLight = ThemeData.light(useMaterial3: true).copyWith(
  scaffoldBackgroundColor: AppColors.scaffoldBackgroundColorLight,
  cardTheme: _cardTheme.copyWith(
    color: Colors.transparent,
  ),
  textTheme: _textTheme.copyWith(
    bodyMedium: _textStyle.copyWith(
      color: AppColors.foregroundColorLight,
    ),
    bodySmall: _textStyle.copyWith(
      color: AppColors.foregroundColorLight,
    ),
    titleMedium: _textStyle.copyWith(
      color: AppColors.foregroundColorLight,
    ),
    titleSmall: _textStyle.copyWith(
      color: AppColors.foregroundColorLight,
    ),
    bodyLarge: _textStyle.copyWith(
      color: AppColors.foregroundColorLight,
    ),
    displaySmall: _textStyle.copyWith(
      color: AppColors.foregroundColorLight,
    ),
    displayLarge: _textStyle.copyWith(
      color: AppColors.foregroundColorLight,
    ),
    headlineLarge: _textStyle.copyWith(
      color: AppColors.foregroundColorLight,
    ),
    displayMedium: _textStyle.copyWith(
      color: AppColors.foregroundColorLight,
    ),
    headlineMedium: _textStyle.copyWith(
      color: AppColors.foregroundColorLight,
    ),
    headlineSmall: _textStyle.copyWith(
      color: AppColors.foregroundColorLight,
    ),
    labelLarge: _textStyle.copyWith(
      color: AppColors.foregroundColorLight,
    ),
    labelMedium: _textStyle.copyWith(
      color: AppColors.foregroundColorLight,
    ),
    labelSmall: _textStyle.copyWith(
      color: AppColors.foregroundColorLight,
    ),
    titleLarge: _textStyle.copyWith(
      color: AppColors.foregroundColorLight,
    ),
  ),
  progressIndicatorTheme: _progressIndicatorTheme,
  inputDecorationTheme: _inputDecorationTheme.copyWith(
    prefixIconColor: AppColors.foregroundColorLight,
    suffixIconColor: AppColors.foregroundColorLight,
  ),
  floatingActionButtonTheme: _floatingActionButtonTheme.copyWith(
    foregroundColor: Colors.white,
  ),
  colorScheme: _colorScheme,
);

const defaultBorderRadius = BorderRadius.all(Radius.circular(32));

const _fontFamily = FontFamily.poppins;

const _textStyle = TextStyle(
  fontFamily: _fontFamily,
  decoration: TextDecoration.none,
);

const _textTheme = TextTheme(
  labelSmall: _textStyle,
  bodySmall: _textStyle,
  labelLarge: _textStyle,
  bodyLarge: _textStyle,
  bodyMedium: _textStyle,
  displayLarge: _textStyle,
  displayMedium: _textStyle,
  displaySmall: _textStyle,
  headlineMedium: _textStyle,
  headlineSmall: _textStyle,
  titleLarge: _textStyle,
  titleMedium: _textStyle,
  titleSmall: _textStyle,
);

const _colorScheme = ColorScheme.dark(
  primary: AppColors.primaryColor,
  secondary: AppColors.secondaryColor,
  tertiary: AppColors.tertiaryColor,
);

const _cardTheme = CardTheme(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: defaultBorderRadius,
    side: BorderSide(
      color: AppColors.secondaryColor,
    ),
  ),
);

const _progressIndicatorTheme = ProgressIndicatorThemeData(
  color: AppColors.loadingIndicatorColor,
);

const _inputDecorationTheme = InputDecorationTheme(
  border: OutlineInputBorder(
    borderRadius: defaultBorderRadius,
    borderSide: BorderSide(
      color: AppColors.secondaryColor,
    ),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: defaultBorderRadius,
    borderSide: BorderSide(
      color: Colors.grey,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: defaultBorderRadius,
    borderSide: BorderSide(
      color: AppColors.primaryColor,
      width: 2,
    ),
  ),
);

const _floatingActionButtonTheme = FloatingActionButtonThemeData(
  shape: RoundedRectangleBorder(
    borderRadius: defaultBorderRadius,
  ),
);

abstract class AppPaddings {
  static const defaultOffset = 72.0;
}

abstract class AppColors {
  static const primaryColor = Color(0xFFE5006A);
  static const secondaryColor = Color(0xFF730A13);
  static const tertiaryColor = Color(0xFF260306);

  static const foregroundColorLight = Color.fromARGB(255, 0, 0, 0);

  static const loadingIndicatorColor = Color(0xFFE5006A);
  static const textColorDark = Color(0xFFE5E5E5);

  static const scaffoldBackgroundColorDark = Color(0xFF0D0D0D);
  static const scaffoldBackgroundColorLight =
      Color.fromARGB(255, 255, 255, 255);
  // static const cardBackgroundColor = Color(0xFF21001A);
  static const highlightColor = Color.fromARGB(129, 255, 191, 0);

  static const warning = Color(0xFFFAE811);
  static const error = Color(0xFFEB0109);
  static const success = Color(0xFF28EF4E);
  static const info = Color(0xFF2283F9);
}
