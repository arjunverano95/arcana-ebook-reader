import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
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
  // OrientationBuilder(builder: (context, orientation) { })
  runApp(ScreenUtilInit(
    designSize: Size(750, 1334),
    allowFontScaling: true,
    child: MaterialApp(
      title: 'Arcana Ebook Reader',
      theme: ThemeData(
        primaryColor: CustomColors.normal,
      ),
      home: Home(),
      // builder: EasyLoading.init(),
    ),
  ));
}
