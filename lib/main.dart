import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:arcana_ebook_reader/util/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          navigatorKey: env.navigation.navigatorKey,
          title: 'Arcana Ebook Reader',
          onGenerateRoute: generateRoute,
          theme: ThemeData(
              primaryColor: CustomColors.normal,
              appBarTheme: AppBarTheme(
                color: CustomColors.normal, //<-- SEE HERE
              )),
          home: child,
          // builder: EasyLoading.init(),
        );
      },
      child: const Home(),
    );
  }
}
