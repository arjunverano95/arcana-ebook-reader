import 'dart:io';
import 'dart:typed_data';

import 'package:arcana_ebook_reader/dto/BookDtos.dart';
import 'package:arcana_ebook_reader/models/Book.dart';
import 'package:epub/epub.dart';
import 'package:hive/hive.dart';
import 'package:image/image.dart';

class BookLibrary {
  static const name = 'books';
  BookLibrary() {
    Hive.registerAdapter(BookAdapter(), override: true);
    //var books = await Hive.openBox('books');
  }

  static Future<List<int>> getCoverImageData(String filePath) async {
    try {
      //get cover
      if (filePath == "") return null;

      // final appDirectory = await getApplicationDocumentsDirectory();
      // final appDirectoryPath = appDirectory.path;
      // final imagePath = '$appDirectoryPath/$coverImage';
      // final imageFile = File(imagePath);
      var epubFile = File(filePath);
      Uint8List bytes = await epubFile.readAsBytes();
      EpubBookRef epubBook = await EpubReader.openBook(bytes);
      Image coverImage = await epubBook.readCover();

      List<int> imageBytes;
      if (coverImage != null) {
        // ImageObj.Image thumbnail = ImageObj.copyResize(coverImage,
        //     width: 390.w.toInt(), height: 530.w.toInt());
        Image thumbnail = copyResize(coverImage, width: 195, height: 265);
        imageBytes = encodeJpg(thumbnail);
        if (imageBytes == null) imageBytes = encodePng(thumbnail);
        if (imageBytes == null) imageBytes = encodeTga(thumbnail);
        if (imageBytes == null) imageBytes = encodeGif(thumbnail);
        if (imageBytes == null) imageBytes = encodeCur(thumbnail);
        if (imageBytes == null) imageBytes = encodeIco(thumbnail);
      }

      // var coverImageData = base64Decode(coverImage);
      // var image = await imageFile.readAsBytes();
      return imageBytes;
    } catch (ex) {
      return null;
    }
  }

  static Future<bool> add(BookDto book) async {
    try {
      //get all books
      List<BookDto> books = await BookLibrary.getAll();

      //title already exist
      List<BookDto> bookToAdd =
          books.where((element) => element.title == book.title).toList();
      if (bookToAdd != null && bookToAdd.length > 0) {
        //Book.delete(book.id);
        book.title = book.title + "(" + (bookToAdd.length + 1).toString() + ")";
      }

      var newBook = Book.fromDto(book);

      var hiveBox = await Hive.openBox<Book>(BookLibrary.name);
      hiveBox.put(newBook.id, newBook);
      await hiveBox.close();

      return true;
    } catch (ex) {
      return false;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      var hiveBox = await Hive.openBox<Book>(BookLibrary.name);
      hiveBox.delete(id);
      await hiveBox.close();

      return true;
    } catch (ex) {
      return false;
    }
  }

  static Future<BookDto> get(String id) async {
    try {
      var hiveBox = await Hive.openBox<Book>(BookLibrary.name);
      Book book = hiveBox.get(id);
      await hiveBox.close();

      return new BookDto.fromBook(book);
    } catch (ex) {
      return null;
    }
  }

  static Future<List<BookDto>> getAll() async {
    try {
      var hiveBox = await Hive.openBox<Book>(BookLibrary.name);
      var library = hiveBox.values.map((e) => new BookDto.fromBook(e)).toList();
      await hiveBox.close();

      return library;
    } catch (ex) {
      return null;
    }
  }

  static Future<bool> updateFavorite(String id) async {
    try {
      var hiveBox = await Hive.openBox<Book>(BookLibrary.name);
      Book bookToUpdate = hiveBox.get(id);

      //update book
      bookToUpdate.isFavorite = bookToUpdate.isFavorite == 1 ? 0 : 1;
      bookToUpdate.save();

      await hiveBox.close();

      return true;
    } catch (ex) {
      return false;
    }
  }

  static Future<bool> updateLastRead(String id) async {
    try {
      var hiveBox = await Hive.openBox<Book>(BookLibrary.name);
      Book bookToUpdate = hiveBox.get(id);

      //update book
      bookToUpdate.lastRead = DateTime.now();
      bookToUpdate.save();

      await hiveBox.close();

      return true;
    } catch (ex) {
      return false;
    }
  }

  static Future<bool> updateLastReadLocator(String id, String locator) async {
    try {
      var hiveBox = await Hive.openBox<Book>(BookLibrary.name);
      Book bookToUpdate = hiveBox.get(id);

      //update book
      bookToUpdate.lastReadLocator = locator;
      bookToUpdate.save();

      await hiveBox.close();

      return true;
    } catch (ex) {
      return false;
    }
  }

  // Future<List<int>> getCoverImageData() async {
  //   if (this.coverImageData == null)
  //     this.coverImageData = await _getCoverImageData(this.filePath);
  //   return this.coverImageData;
  // }

}