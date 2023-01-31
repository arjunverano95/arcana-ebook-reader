import 'dart:io';

import 'package:flutter/services.dart';

import 'package:epubx/epubx.dart';
import 'package:image/image.dart';

import 'package:arcana_ebook_reader/dto/BookDtos.dart';
import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/models/Book.dart';

class BookLibrary {
  static const name = 'books';
  BookLibrary() {
    //var books = Hive.box('books');
  }

  static Future<List<int>> getCoverImageData(String filePath) async {
    var assetFile = await rootBundle.load('assets/images/no_cover.jpg');
    var noCoverImage = assetFile.buffer
        .asUint8List(assetFile.offsetInBytes, assetFile.lengthInBytes);
    try {
      //get cover
      if (filePath == "") return noCoverImage.buffer.asUint8List();
      var epubFile = File(filePath);
      Uint8List bytes = await epubFile.readAsBytes();
      EpubBookRef epubBook = await EpubReader.openBook(bytes);
      Image? coverImage = await epubBook.readCover();

      if (coverImage != null) {
        List<int> imageBytes = [];

        Image thumbnail = copyResize(coverImage, width: 195, height: 265);
        imageBytes = encodeJpg(thumbnail);
        // imageBytes = thumbnail.getBytes();

        return imageBytes;
      }
      return noCoverImage;
    } catch (ex) {
      return noCoverImage;
    }
  }

  static Future<bool> add(BookDto book) async {
    try {
      //get all books
      List<BookDto> books = await BookLibrary.getAll();

      //title already exist
      List<BookDto> bookToAdd =
          books.where((element) => element.title == book.title).toList();
      if (bookToAdd.isNotEmpty) {
        //Book.delete(book.id);
        book.title = "${book.title}(${bookToAdd.length + 1})";
      }

      var hiveBox = env.context.books;
      var newBook = Book.fromDto(book);
      await hiveBox.put(newBook.id, newBook);

      return true;
    } catch (ex) {
      return false;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      var hiveBox = env.context.books;
      await hiveBox.delete(id);

      return true;
    } catch (ex) {
      return false;
    }
  }

  static Future<BookDto?> get(String id) async {
    try {
      var hiveBox = env.context.books;
      Book? book = hiveBox.get(id);

      if (book != null) return BookDto.fromBook(book);
      return null;
    } catch (ex) {
      return null;
    }
  }

  static Future<List<BookDto>> getAll() async {
    try {
      var hiveBox = env.context.books;
      var library = hiveBox.values.map((e) => BookDto.fromBook(e)).toList();

      return library;
    } catch (ex) {
      return [];
    }
  }

  static Future<bool> updateFavorite(String id) async {
    try {
      var hiveBox = env.context.books;
      Book? bookToUpdate = hiveBox.get(id);
      if (bookToUpdate != null) {
        //update book
        bookToUpdate.isFavorite = bookToUpdate.isFavorite == 1 ? 0 : 1;
        await bookToUpdate.save();

        return true;
      }
      return false;
    } catch (ex) {
      return false;
    }
  }

  static Future<bool> updateLastRead(String id) async {
    try {
      var hiveBox = env.context.books;
      Book? bookToUpdate = hiveBox.get(id);
      if (bookToUpdate != null) {
        //update book
        bookToUpdate.lastRead = DateTime.now();
        await bookToUpdate.save();

        return true;
      }

      return false;
    } catch (ex) {
      return false;
    }
  }

  static Future<bool> updateLastReadLocator(String id, String locator) async {
    try {
      var hiveBox = env.context.books;
      Book? bookToUpdate = hiveBox.get(id);
      if (bookToUpdate != null) {
        //update book
        bookToUpdate.lastReadLocator = locator;
        await bookToUpdate.save();

        return true;
      }

      return false;
    } catch (ex) {
      return false;
    }
  }
}
