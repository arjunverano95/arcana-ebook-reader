import 'dart:io';

import 'package:flutter/material.dart';

import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/models/Book.dart';
import 'package:arcana_ebook_reader/screens/epub_reader.dart';
import 'package:arcana_ebook_reader/services/database_service.dart';

Future<void> readEbook(Book book) async {
  if (book.fileType == "epub") {
    _epubViewer(book);
  }

  DatabaseService.updateLastRead(
    book.id,
  ).whenComplete(() => env.bookstore.getBooks());
}

void _epubViewer(Book book) {
  String filePath = book.filePath;
  var epubFile = File(filePath);
  if (epubFile.existsSync()) {
    Navigator.of(env.navigation.navigatorKey.currentContext!).push(
      MaterialPageRoute(
        builder: (context) => EpubReaderScreen(book: book, filePath: filePath),
      ),
    );
  } else {
    DatabaseService.deleteBook(
      book.id,
    ).whenComplete(() => env.bookstore.getBooks());
  }
}
