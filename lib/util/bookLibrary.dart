import 'dart:developer' as developer;

import 'package:flutter/services.dart';

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
    var noCoverImage = assetFile.buffer.asUint8List(
      assetFile.offsetInBytes,
      assetFile.lengthInBytes,
    );
    try {
      //get cover
      if (filePath.isEmpty) return noCoverImage;

      // For now, return the default cover image
      // In a future implementation, you could extract cover from EPUB using vocsy_epub_viewer
      // or implement a separate EPUB parser for metadata extraction
      return noCoverImage;
    } catch (ex) {
      developer.log('Error getting cover image: $ex', name: 'BookLibrary');
      return noCoverImage;
    }
  }

  static Future<bool> add(BookDto book) async {
    try {
      var hiveBox = env.context.books;

      // Optimized duplicate check - only check if title is not empty
      if (book.title.isNotEmpty) {
        final existingBooks = hiveBox.values
            .where((element) => element.title == book.title)
            .toList();

        if (existingBooks.isNotEmpty) {
          book.title = "${book.title}(${existingBooks.length + 1})";
        }
      }

      var newBook = Book.fromDto(book);
      await hiveBox.put(newBook.id, newBook);
      developer.log(
        'Book added successfully: ${book.title}',
        name: 'BookLibrary',
      );
      return true;
    } catch (ex) {
      developer.log('Error adding book: $ex', name: 'BookLibrary');
      return false;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      var hiveBox = env.context.books;
      await hiveBox.delete(id);
      developer.log('Book deleted successfully: $id', name: 'BookLibrary');
      return true;
    } catch (ex) {
      developer.log('Error deleting book: $ex', name: 'BookLibrary');
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
      developer.log('Error getting book: $ex', name: 'BookLibrary');
      return null;
    }
  }

  static Future<List<BookDto>> getAll() async {
    try {
      var hiveBox = env.context.books;
      var library = hiveBox.values.map((e) => BookDto.fromBook(e)).toList();
      return library;
    } catch (ex) {
      developer.log('Error getting all books: $ex', name: 'BookLibrary');
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
        developer.log('Book favorite updated: $id', name: 'BookLibrary');
        return true;
      }
      return false;
    } catch (ex) {
      developer.log('Error updating favorite: $ex', name: 'BookLibrary');
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
        developer.log('Book last read updated: $id', name: 'BookLibrary');
        return true;
      }

      return false;
    } catch (ex) {
      developer.log('Error updating last read: $ex', name: 'BookLibrary');
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
        developer.log('Book locator updated: $id', name: 'BookLibrary');
        return true;
      }

      return false;
    } catch (ex) {
      developer.log('Error updating locator: $ex', name: 'BookLibrary');
      return false;
    }
  }
}
