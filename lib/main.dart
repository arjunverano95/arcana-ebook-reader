import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:arcana_ebook_reader/util/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:flutter/services.dart';
import 'screens/home.dart';

//void main() => runApp(Login());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await BuildEnvironment.init();
  await Hive.initFlutter();

  // OrientationBuilder(builder: (context, orientation) { })
  runApp(ScreenUtilInit(
    designSize: Size(750, 1334),
    // allowFontScaling: true,
    builder: () => MaterialApp(
      navigatorKey: env.navigation.navigatorKey,
      title: 'Arcana Ebook Reader',
      onGenerateRoute: generateRoute,
      theme: ThemeData(
        primaryColor: CustomColors.normal,
      ),
      home: Home(),
      // builder: EasyLoading.init(),
    ),
  ));
}
