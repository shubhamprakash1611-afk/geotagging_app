import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

class GeoTaggingApp extends StatelessWidget {
  const GeoTaggingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoTag Camera',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            // Preserve accessibility without allowing extreme system font
            // sizes to break compact camera controls and settings segments.
            textScaler: mediaQuery.textScaler.clamp(maxScaleFactor: 1.5),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.accentGreen,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentGreen,
          onPrimary: Color(0xFF042117),
          secondary: AppColors.accentCyan,
          onSecondary: Color(0xFF031D27),
          surface: AppColors.surfaceDark,
          onSurface: AppColors.textPrimary,
          outline: AppColors.outline,
        ),
        fontFamily: 'Roboto',
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.accentGreen,
          linearTrackColor: AppColors.outline,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surfaceRaised,
          contentTextStyle: const TextStyle(color: AppColors.textPrimary),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          surfaceTintColor: Colors.transparent,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surfaceRaised,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        splashFactory: InkSparkle.splashFactory,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          },
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
