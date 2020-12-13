import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'screens/home.dart';

//void main() => runApp(Login());
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIOverlays([]);
  await BuildEnvironment.init();
  runApp(MaterialApp(
      title: 'Arcana Ebook Reader',
      theme: ThemeData(
        primaryColor: CustomColors.normal,
      ),
      home: Home()));
}
