import 'dart:convert';

import 'package:arcana_ebook_reader/dto/BookDtos.dart';
import 'package:arcana_ebook_reader/util/bookLibrary.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:epub_viewer/epub_viewer.dart';
import 'package:arcana_ebook_reader/env.dart';

Future<void> readEbook(BookDto book) async {
  if (book.fileType == "epub") {
    _epubViewer(book);
  }
  BookLibrary.updateLastRead(book.id)
      .whenComplete(() => env.bookstore.getBooks());
}

void _epubViewer(BookDto book) {
  String path = book.filePath;
  // TODO Ebook not found. delete?
  EpubViewer.setConfig(
    themeColor: CustomColors.normal,
    identifier: "book",
    scrollDirection: EpubScrollDirection.VERTICAL,
    allowSharing: true,
    enableTts: true,
    nightMode: false,
  );

  EpubViewer.open(
    path,
    lastLocation: book.lastReadLocator == ""
        ? null
        : EpubLocator.fromJson(
            jsonDecode(book.lastReadLocator),
          ),
  );

  EpubViewer.locatorStream.listen((locator) {
    BookLibrary.updateLastReadLocator(book.id, locator)
        .whenComplete(() => env.bookstore.getBooks());
  });
}

  // const pageChannel = const EventChannel('com.jideguru.epub_viewer/page');
  // pageChannel.receiveBroadcastStream().listen((event) {
  //   print(event);
  // });