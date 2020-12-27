import 'dart:convert';

import 'package:arcana_ebook_reader/util/context.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:epub_viewer/epub_viewer.dart';
import 'package:arcana_ebook_reader/env.dart';

Future<void> readEbook(Book book) async {
  if (book.fileType == "epub") {
    await _epubViewer(book);
  }
  book.updateLastRead().then((value) => env.bookstore.getBooks());
}

Future<void> _epubViewer(Book book) async {
  String path = await book.getPath();
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
    lastLocation: book.lastReadLocator == null || book.lastReadLocator == ""
        ? null
        : EpubLocator.fromJson(
            jsonDecode(book.lastReadLocator),
          ),
    //  EpubLocator.fromJson({
    //   "bookId": "urn:uuid:f2e09c5f-8c99-4ad9-b8fa-1994040befa8",
    //   "href": "/OEBPS/Text/Chapter1.xhtml",
    //   "created": 1609063079093,
    //   "locations": {"cfi": "epubcfi(/0!/4/2/1:0)"},
    //   "title": ""
    // }),
  );

  EpubViewer.locatorStream.listen((locator) {
    book
        .updateLastReadLocator(locator)
        .then((value) => env.bookstore.getBooks());
    // print('LOCATOR: ${EpubLocator.fromJson(jsonDecode(locator))}');
  });
}