import 'dart:io';

import 'package:arcana_ebook_reader/util/context.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:epub/epub.dart' as Epub;
import 'package:image/image.dart' as ImageObj;

void openFileDialog(Function(bool) setLoading, Function(double) reportProgress,
    Function callback) async {
  setLoading(true);
  reportProgress(null);
  FilePickerResult result = await FilePicker.platform.pickFiles(
    allowMultiple: false,
    type: FileType.custom,
    allowedExtensions: ['epub'],
  );
  if (result != null) {
    if (result.files.length > 0) {
      _importBooks(result.files, reportProgress).then((value) {
        setLoading(false);
        callback();
      });
    } else {
      setLoading(false);
    }
  } else {
    setLoading(false);
  }
}

Future<void> _importBooks(
    List<PlatformFile> files, Function(double) reportProgress) async {
  double iter = ((100 / files.length) / 4) * 0.01;
  double pg = 0.0;

  reportProgress(pg);
  for (var i = 0; i < files.length; i++) {
    PlatformFile file = files[i];
    if (file.extension.toLowerCase() == "epub") {
      String uKey = Uuid().v1();
      var epubFile = File(file.path);
      List<int> bytes = await epubFile.readAsBytes();
      pg += iter;
      reportProgress(pg);

      Epub.EpubBookRef epubBook = await Epub.EpubReader.openBook(bytes);

      pg += iter;
      reportProgress(pg);

      ImageObj.Image coverImage = await epubBook.readCover();

      pg += iter;
      reportProgress(pg);

      List<int> imageBytes;
      if (coverImage != null) {
        ImageObj.Image thumbnail =
            ImageObj.copyResize(coverImage, width: 195, height: 265);
        imageBytes = ImageObj.encodeJpg(thumbnail, quality: 90);
      }

      Book newBook = new Book();
      newBook.id = uKey;
      newBook.title = epubBook.Title;
      newBook.author = epubBook.Author;
      newBook.addedDate = DateTime.now();
      newBook.lastRead = DateTime.now();
      newBook.isFavorite = 0;
      await Book.add(newBook, file.extension, bytes, imageBytes);

      pg += iter;
      reportProgress(pg);
    }
  }
}
