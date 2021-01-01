import 'package:arcana_ebook_reader/screens/favorites.dart';
import 'package:arcana_ebook_reader/screens/home.dart';
import 'package:arcana_ebook_reader/screens/library.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  // final args = settings.arguments;

  switch (settings.name) {
    case 'home':
      return MaterialPageRoute(
          settings: settings, builder: (context) => Home());

    case 'favorites':
      return MaterialPageRoute(
          settings: settings, builder: (context) => Favorites());

    case 'library':
      return MaterialPageRoute(
          settings: settings, builder: (context) => Library());

// TODO 
    default:
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('Error Loading Screen'),
          ),
        ),
      );
  }
}
