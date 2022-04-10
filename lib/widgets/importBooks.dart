import 'dart:io';
import 'dart:typed_data';

import 'package:arcana_ebook_reader/dto/BookDtos.dart';
import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/util/bookLibrary.dart';
import 'package:arcana_ebook_reader/widgets/ebookReader.dart';
import 'package:epub/epub.dart';
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
        var books = await _importBooks(result.files);
        env.bookstore.getBooks();
        if (books.length == 1) readEbook(books[0]);
      }
    }
  }
}

// This function happens in the isolate.
// void importBooks(Map<String, dynamic> context) {
//   final messenger = HandledIsolate.initialize(context);

//   messenger.listen((message) async {
//     var files = (json.decode(message) as List)
//         .map((e) => {
//               "path": e.path.toString(),
//               "extension": e.extension.toString(),
//             })
//         .toList();
//     bool value = await _importBooks(files);
//     messenger.send(value);
//   });
// }

Future<List<BookDto>> _importBooks(List<PlatformFile> files) async {
  List<BookDto> res = [];
  for (var i = 0; i < files.length; i++) {
    PlatformFile file = files[i];

    String filePath = file.path;
    int fileSize = file.size;
    String fileExt = file.extension.toLowerCase();
    if (fileExt == "epub") {
      String uKey = Uuid().v1();
      var epubFile = File(filePath);
      Uint8List bytes = await epubFile.readAsBytes();

      EpubBookRef epubBook = await EpubReader.openBook(bytes);

      BookDto newBook = BookDto();
      newBook.id = uKey;
      newBook.title = epubBook.Title;
      newBook.author = epubBook.Author;
      newBook.addedDate = DateTime.now();
      // newBook.lastRead = DateTime.now();
      newBook.isFavorite = 0;

      newBook.filePath = filePath;
      newBook.fileSize = fileSize;
      newBook.fileType = fileExt;
      // await BookDto.add(newBook, fileExt, fileSize, bytes, imageBytes);
      await BookLibrary.add(newBook);
      res.add(newBook);
    }
  }
  return res;
}
