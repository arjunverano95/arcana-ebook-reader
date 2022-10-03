import 'dart:io';
import 'dart:typed_data';

import 'package:arcana_ebook_reader/dto/BookDtos.dart';
import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/util/bookLibrary.dart';
import 'package:arcana_ebook_reader/widgets/ebookReader.dart';
import 'package:epubx/epubx.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

Future<void> showImportDialog() async {
  if (await Permission.storage.request().isGranted) {
    var result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );

    if (result != null) {
      if (result.files.length > 0) {
        // var toRead = await flutterCompute(_importBooks, result.files);
        if (result.files.length == 1) {
          var file = result.files[0];
          var toRead = await _importBook(file)
              .whenComplete(() => env.bookstore.getBooks());

          if (toRead != null) {
            var book = await BookLibrary.get(toRead);
            if (book != null) readEbook(book);
          }
        } else {
          await Future.wait(result.files.map((file) async {
            await _importBook(file);
          })).whenComplete(() => env.bookstore.getBooks());
        }
      }
    }
  }
}

Future<String?> _importBook(PlatformFile file) async {
  String filePath = file.path ?? '';
  int fileSize = file.size;
  String fileExt = file.extension ?? ''.toLowerCase();
  if (fileExt == "epub") {
    String uKey = Uuid().v1();
    var epubFile = File(filePath);
    Uint8List bytes = await epubFile.readAsBytes();

    EpubBookRef epubBook = await EpubReader.openBook(bytes);

    BookDto newBook = BookDto();
    newBook.id = uKey;
    newBook.title = epubBook.Title ?? '';
    newBook.author = epubBook.Author ?? '';
    newBook.addedDate = DateTime.now();
    // newBook.lastRead = DateTime.now();
    newBook.isFavorite = 0;

    newBook.filePath = filePath;
    newBook.fileSize = fileSize;
    newBook.fileType = fileExt;
    newBook.coverImageData = await BookLibrary.getCoverImageData(filePath);
    await BookLibrary.add(newBook);
    return newBook.id;
  }
  return null;
}
