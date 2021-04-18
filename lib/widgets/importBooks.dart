import 'dart:io';
import 'dart:typed_data';

import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/util/context.dart';
import 'package:arcana_ebook_reader/widgets/ebookReader.dart';
import 'package:epub/epub.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

Future<void> showImportDialog() async {
  if (await Permission.storage.request().isGranted) {
    // final isolates = IsolateHandler();
    var result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );

    if (result != null) {
      if (result.files.length > 0) {
        // String file = jsonEncode(result.files
        //     .map((e) => {
        //           "path": e.path,
        //           "extension": e.extension,
        //         })
        //     .toList());

        // isolates.spawn<bool>(importBooks,
        //     name: 'importBooks',
        //     onReceive: (value) {
        //       isolates.kill('importBooks');
        //       env.bookstore.getBooks();
        //     },
        //     onInitialized: () => isolates.send(file, to: 'importBooks'));
        // await compute(_importBooks, result.files);
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

Future<List<Book>> _importBooks(List<PlatformFile> files) async {
  List<Book> res = [];
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

      Book newBook = Book();
      newBook.id = uKey;
      newBook.title = epubBook.Title;
      newBook.author = epubBook.Author;
      newBook.addedDate = DateTime.now();
      // newBook.lastRead = DateTime.now();
      newBook.isFavorite = 0;
      // await Book.add(newBook, fileExt, fileSize, bytes, imageBytes);
      await Book.add(newBook, fileExt, fileSize, filePath);
      res.add(newBook);
    }
  }
  return res;
}
