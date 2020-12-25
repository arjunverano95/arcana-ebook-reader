import 'dart:convert';

import 'package:arcana_ebook_reader/util/context.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:epub_viewer/epub_viewer.dart';

Future<void> readEbook(Book book) async {
  book.updateLastRead();
  if (book.fileType == "epub") {
    await _epubViewer(book);
  }
}

Future<void> _epubViewer(Book book) async {
  String path = await book.getPath();
  EpubViewer.setConfig(
    themeColor: CustomColors.normal,
    identifier: "book",
    scrollDirection: EpubScrollDirection.VERTICAL,
    allowSharing: false,
    enableTts: false,
    nightMode: false,
  );

  EpubViewer.open(path, lastLocation: null);
  EpubViewer.locatorStream.listen((locator) {
    print('LOCATOR: ${EpubLocator.fromJson(jsonDecode(locator))}');
  });
}
