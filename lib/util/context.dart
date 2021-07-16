import 'dart:io';
import 'dart:typed_data';

import 'package:epub/epub.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart';

class Book {
  String id;
  String title;
  String author;
  // int pagelength;
  // int progressPage;
  // int progressPercent;
  DateTime lastRead;
  DateTime addedDate;
  int isFavorite;
  String filePath;
  String fileType;
  int fileSize;
  String lastReadLocator;
  List<int> coverImageData;

  Book()
      : id = "",
        title = "",
        author = "",
        // pagelength = 0,
        // progressPage = 0,
        // progressPercent = 0,
        lastRead = null,
        addedDate = null,
        isFavorite = 0,
        filePath = "",
        fileType = "",
        fileSize = 0,
        lastReadLocator = "",
        coverImageData = null;

  Book.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        author = json['author'],
        // pagelength = json['pagelength'],
        // progressPage = json['progressPage'],
        // progressPercent = json['progressPercent'],
        lastRead = DateTime.tryParse(json['lastRead'] ?? ""),
        addedDate = DateTime.tryParse(json['addedDate'] ?? ""),
        isFavorite = json['isFavorite'],
        filePath = json['filePath'],
        fileType = json['fileType'],
        fileSize = json['fileSize'],
        lastReadLocator = json['lastReadLocator'];

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "author": author,
        // "pagelength": pagelength,
        // "progressPage": progressPage,
        // "progressPercent": progressPercent,
        "lastRead": lastRead != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(lastRead)
            : "",
        "addedDate": addedDate != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(addedDate)
            : "",
        "isFavorite": isFavorite,
        "filePath": filePath,
        "fileType": fileType,
        "fileSize": fileSize,
        "lastReadLocator": lastReadLocator,
        // "coverImage": coverImage
      };

  // static Future<String> _addToDir(String filename, List<int> data) async {
  //   //check book on AppData
  //   final appDirectory = await getApplicationDocumentsDirectory();
  //   final appDirectoryPath = appDirectory.path;
  //   final bookPath = '$appDirectoryPath/$filename';
  //   final bookFile = File(bookPath);

  //   await bookFile.create();
  //   await bookFile.writeAsBytes(data);
  //   return filename;
  // }

  // static Future<void> _deleteToDir(String filename) async {
  //   //check book on AppData
  //   final appDirectory = await getApplicationDocumentsDirectory();
  //   final appDirectoryPath = appDirectory.path;
  //   final bookPath = '$appDirectoryPath/$filename';
  //   final bookFile = File(bookPath);
  //   final exists = await bookFile.exists();
  //   //overwrite
  //   if (exists) {
  //     await bookFile.delete();
  //   }
  // }

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

  static Future<void> _updateLibrary(List<Book> books) async {
    var jsonString = jsonEncode(books.map((e) => e.toJson()).toList());

    //check library on AppData
    final appDirectory = await getApplicationDocumentsDirectory();
    final appDirectoryPath = appDirectory.path;
    final configPath = '$appDirectoryPath/library.json';
    final libraryFile = File(configPath);
    await libraryFile.writeAsString(jsonString);
  }

  static Future<bool> add(
      Book newBook, String fileExtension, int fileSize, String filePath) async {
    try {
      //get all books
      List<Book> books = await Book.get();

      //title already exist
      List<Book> bookToAdd =
          books.where((element) => element.title == newBook.title).toList();
      if (bookToAdd != null && bookToAdd.length > 0) {
        //Book.delete(bookToAdd.id);
        newBook.title =
            newBook.title + "(" + (bookToAdd.length + 1).toString() + ")";
      }

      newBook.filePath = filePath;
      newBook.fileType = fileExtension;
      newBook.fileSize = fileSize;
      books.add(newBook);

      await Book._updateLibrary(books);

      return true;
    } catch (ex) {
      return false;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      //get all books
      List<Book> books = await Book.get();
      books.removeWhere((element) => element.id == id);

      await Book._updateLibrary(books);

      return true;
    } catch (ex) {
      return false;
    }
  }

  static Future<List<Book>> get() async {
    try {
      //check libray on AppData
      final appDirectory = await getApplicationDocumentsDirectory();
      final appDirectoryPath = appDirectory.path;
      final configPath = '$appDirectoryPath/library.json';
      final libraryFile = File(configPath);
      final exists = await libraryFile.exists();
      //if not exist copy template from asset
      if (!exists) {
        await libraryFile.create();
        String jsonString =
            await rootBundle.loadString('assets/data/library.json');
        await libraryFile.writeAsString(jsonString);
      }
      // Read the libray.
      String jsonString = await libraryFile.readAsString();

      var library = (json.decode(jsonString) as List)
          .map((i) => Book.fromJson(i))
          .toList();

      // for (var i = 0; i < library.length; i++) {
      //   library[i].coverImageData =await Book._getCoverImageData(library[i].coverImage);
      // }
      return library;
    } catch (ex) {
      return null;
    }
  }

  Future<bool> updateFavorite() async {
    try {
      //get all books
      List<Book> books = await Book.get();
      Book bookToUpdate = books.singleWhere((element) => element.id == id);

      //update book
      bookToUpdate.isFavorite = bookToUpdate.isFavorite == 1 ? 0 : 1;
      books[books.indexWhere((element) => element.id == id)] = bookToUpdate;

      await Book._updateLibrary(books);

      return true;
    } catch (ex) {
      return false;
    }
  }

  Future<bool> updateLastRead() async {
    try {
      //get all books
      List<Book> books = await Book.get();
      Book bookToUpdate = books.singleWhere((element) => element.id == id);

      //update book
      bookToUpdate.lastRead = DateTime.now();
      books[books.indexWhere((element) => element.id == id)] = bookToUpdate;

      await Book._updateLibrary(books);

      return true;
    } catch (ex) {
      return false;
    }
  }

  Future<bool> updateLastReadLocator(String locator) async {
    try {
      //get all books
      List<Book> books = await Book.get();
      Book bookToUpdate = books.singleWhere((element) => element.id == id);

      //update book
      bookToUpdate.lastReadLocator = locator;
      books[books.indexWhere((element) => element.id == id)] = bookToUpdate;

      await Book._updateLibrary(books);

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
  void setCoverImageData(List<int> bytes) {
    this.coverImageData = bytes;
  }

  String getPath() {
    return this.filePath;
  }
}
