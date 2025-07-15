import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:arcana_ebook_reader/util/routes.dart';
import 'screens/home.dart';

// import 'package:flutter/services.dart';

//void main() => runApp(Login());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await BuildEnvironment.init();
  runApp(const ArcanaEbookReader());
}

class ArcanaEbookReader extends StatelessWidget {
  const ArcanaEbookReader({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(750, 1334),
      // allowFontScaling: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: env.navigation.navigatorKey,
          title: 'Arcana Ebook Reader',
          onGenerateRoute: generateRoute,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: CustomColors.primary,
              brightness: Brightness.light,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: CustomColors.primary,
              foregroundColor: CustomColors.textOnPrimary,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                color: CustomColors.textOnPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            cardTheme: CardThemeData(
              color: CustomColors.cardBackground,
              elevation: 2,
              shadowColor: CustomColors.cardShadow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.primary,
                foregroundColor: CustomColors.textOnPrimary,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            textTheme: const TextTheme(
              headlineLarge: TextStyle(
                color: CustomColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              headlineMedium: TextStyle(
                color: CustomColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
              titleLarge: TextStyle(
                color: CustomColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              titleMedium: TextStyle(
                color: CustomColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              bodyLarge: TextStyle(
                color: CustomColors.textPrimary,
                fontSize: 16,
              ),
              bodyMedium: TextStyle(
                color: CustomColors.textSecondary,
                fontSize: 14,
              ),
              labelLarge: TextStyle(
                color: CustomColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          home: child,
          // builder: EasyLoading.init(),
        );
      },
      child: const Home(),
    );
  }
}
