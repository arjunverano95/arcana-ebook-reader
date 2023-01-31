import 'package:flutter/material.dart';

import 'package:arcana_ebook_reader/screens/favorites.dart';
import 'package:arcana_ebook_reader/screens/home.dart';
import 'package:arcana_ebook_reader/screens/library.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case 'home':
      return MaterialPageRoute(
          settings: settings, builder: (context) => const Home());

    case 'favorites':
      return MaterialPageRoute(
          settings: settings, builder: (context) => const Favorites());

    case 'library':
      return MaterialPageRoute(
          settings: settings, builder: (context) => const Library());

// TODO
    default:
      return MaterialPageRoute(
        builder: (context) => const SafeArea(
          child: Scaffold(
            body: Center(
              child: Text('Error Loading Screen'),
            ),
          ),
        ),
      );
  }
}
