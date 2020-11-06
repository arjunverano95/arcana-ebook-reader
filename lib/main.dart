import 'package:flutter/material.dart';
import 'screens/home.dart';


//void main() => runApp(Login());
Future<void> main() async {
 WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Arcana Ebook Reader',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Home()));
}
