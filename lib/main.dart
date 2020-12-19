import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter/services.dart';
import 'screens/home.dart';

//void main() => runApp(Login());
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIOverlays([]);
  await BuildEnvironment.init();
  runApp(OrientationBuilder(builder: (context, orientation) {
    return ScreenUtilInit(
      designSize: orientation == Orientation.portrait
          ? Size(750, 1334)
          : Size(1334, 750),
      allowFontScaling: true,
      child: MaterialApp(
        title: 'Arcana Ebook Reader',
        theme: ThemeData(
          primaryColor: CustomColors.normal,
        ),
        home: Home(),
        // builder: EasyLoading.init(),
      ),
    );
  }));
}
