import 'package:flutter/material.dart';
import 'package:intellitask/gen/fonts.gen.dart';

final appTheme = ThemeData.dark(useMaterial3: true).copyWith(
  scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
  cardTheme: _cardTheme,
  textTheme: _textTheme,
  progressIndicatorTheme: _progressIndicatorTheme,
);

const _fontFamily = FontFamily.poppins;

const _textStyle = TextStyle(
  color: Colors.white,
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

const _cardTheme = CardTheme(
  elevation: 0,
  color: AppColors.cardBackgroundColor,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  ),
);

const _progressIndicatorTheme = ProgressIndicatorThemeData(
  color: AppColors.loadingIndicatorColor,
);

abstract class AppPaddings {
  static const defaultOffset = 72.0;
}

abstract class AppColors {
  static const primaryColor = Color(0xFFE5006A);
  static const secondaryColor = Color(0xFF142F40);
  static const accentColor = Color(0xFF0A1926);

  static const loadingIndicatorColor = Color(0xFFE5006A);

  static const scaffoldBackgroundColor = Color(0xFF0D0D0D);
  static const cardBackgroundColor = secondaryColor;
  static const highlightColor = Color.fromARGB(129, 255, 191, 0);

  static const warning = Color(0xFFFAE811);
  static const error = Color(0xFFEB0109);
  static const success = Color(0xFF28EF4E);
  static const info = Color(0xFF2283F9);
}
