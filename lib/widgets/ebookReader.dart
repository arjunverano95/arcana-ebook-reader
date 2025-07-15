import 'dart:convert';
import 'dart:io';

import 'package:vocsy_epub_viewer/epub_viewer.dart';

import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/models/Book.dart';
import 'package:arcana_ebook_reader/services/database_service.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';

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
    VocsyEpub.setConfig(
      themeColor: CustomColors.normal,
      identifier: "book",
      scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
      allowSharing: true,
      enableTts: true,
      nightMode: false,
    );

    VocsyEpub.locatorStream.listen((locator) {
      DatabaseService.updateLastReadLocator(
        book.id,
        locator,
      ).whenComplete(() => env.bookstore.getBooks());
    });

    VocsyEpub.open(
      filePath,
      lastLocation: book.lastReadLocator == ""
          ? null
          : EpubLocator.fromJson(jsonDecode(book.lastReadLocator)),
    );
  } else {
    DatabaseService.deleteBook(
      book.id,
    ).whenComplete(() => env.bookstore.getBooks());
  }
}

// const pageChannel = const EventChannel('com.jideguru.epub_viewer/page');
// pageChannel.receiveBroadcastStream().listen((event) {
//   print(event);
// });
