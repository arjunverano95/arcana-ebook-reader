import 'dart:io';
import 'dart:typed_data';

import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/util/context.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:isolate_handler/isolate_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:epub/epub.dart' as Epub;
import 'package:image/image.dart' as ImageObj;

Future<void> showImportDialog() async {
  if (await Permission.storage.request().isGranted) {
    // final isolates = IsolateHandler();
    FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['epub'],
    ).then((result) async {
      if (result != null) {
        if (result.files.length > 0) {
          // SINGLE FILE ONLY

          // String file = result.files[0].path  + "|"+  result.files[0].extension.toLowerCase();
          // isolates.spawn<bool>(importBooks,
          //     name: 'importBooks',
          //     onReceive: (value) {
          //       isolates.kill('importBooks');
          //     },
          //     onInitialized: () =>
          //         isolates.send(file, to: 'importBooks'));
          _importBooks(
                  result.files[0].path, result.files[0].extension.toLowerCase())
              .then((value) => env.bookstore.getBooks());
        }
      }
    });
  }
}

// This function happens in the isolate.
// void importBooks(Map<String, dynamic> context) {
//   final messenger = HandledIsolate.initialize(context);

//   messenger.listen((file) async {
//     List<String> fileObj = file.toString().split("|");
//     String filePath = fileObj[0];
//     String fileExt = fileObj[1];
//     bool value = await _importBooks(filePath,fileExt);
//     messenger.send(value);
//   });
// }

Future<bool> _importBooks(String filePath, String fileExt) async {
  // List<PlatformFile> files

  //for (var i = 0; i < files.length; i++) {
  //PlatformFile file = files[0];
  if (fileExt == "epub") {
    String uKey = Uuid().v1();
    var epubFile = File(filePath);
    Uint8List bytes = await epubFile.readAsBytes();

    Epub.EpubBookRef epubBook = await Epub.EpubReader.openBook(bytes);

    ImageObj.Image coverImage = await epubBook.readCover();

    List<int> imageBytes;
    if (coverImage != null) {
      ImageObj.Image thumbnail =
          ImageObj.copyResize(coverImage, width: 195, height: 265);
      imageBytes = ImageObj.encodeJpg(thumbnail);
      if (imageBytes == null) imageBytes = ImageObj.encodePng(thumbnail);
      //if(imageBytes == null) imageBytes = ImageObj.encodeGif(thumbnail);
    }

    Book newBook = new Book();
    newBook.id = uKey;
    newBook.title = epubBook.Title;
    newBook.author = epubBook.Author;
    newBook.addedDate = DateTime.now();
    newBook.lastRead = DateTime.now();
    newBook.isFavorite = 0;
    await Book.add(newBook, fileExt, bytes, imageBytes);
  }
  //}
  return true;
}
