import 'dart:developer' as developer;

import 'package:flutter/services.dart';

import 'package:drift/drift.dart';

import 'package:arcana_ebook_reader/database/database.dart' as db;
import 'package:arcana_ebook_reader/models/Book.dart';

class DatabaseService {
  static db.AppDatabase? _database;
  static db.AppDatabase get database => _database!;

  static Future<void> initialize() async {
    _database = db.AppDatabase();
    developer.log('Database initialized successfully', name: 'DatabaseService');
  }

  static Future<void> close() async {
    await _database?.close();
    developer.log('Database closed successfully', name: 'DatabaseService');
  }

  // Cover image utilities
  static Future<List<int>> getCoverImageData(String filePath) async {
    var assetFile = await rootBundle.load('assets/images/no_cover.jpg');
    var noCoverImage = assetFile.buffer.asUint8List(
      assetFile.offsetInBytes,
      assetFile.lengthInBytes,
    );
    try {
      if (filePath.isEmpty) return noCoverImage;

      // For now, return the default cover image
      // In a future implementation, you could extract cover from EPUB using flutter_epub_viewer
      // or implement a separate EPUB parser for metadata extraction
      return noCoverImage;
    } catch (ex) {
      developer.log('Error getting cover image: $ex', name: 'DatabaseService');
      return noCoverImage;
    }
  }

  // Book operations
  static Future<bool> addBook(Book book) async {
    try {
      // Check for duplicates
      if (book.title.isNotEmpty) {
        final existingBooks = await searchBooks(book.title);
        if (existingBooks.isNotEmpty) {
          book = book.copyWith(
            title: "${book.title}(${existingBooks.length + 1})",
          );
        }
      }

      final bookData = db.BooksCompanion.insert(
        id: book.id,
        title: book.title,
        author: book.author,
        lastRead: Value(book.lastRead),
        addedDate: book.addedDate,
        isFavorite: book.isFavorite,
        filePath: book.filePath,
        fileType: book.fileType,
        fileSize: book.fileSize,
        lastReadLocator: book.lastReadLocator,
        coverImageData: Uint8List.fromList(book.coverImageData),
        totalPages: Value(book.totalPages),
        currentPage: Value(book.currentPage),
        progressPercent: Value(book.progressPercent),
        description: Value(book.description),
        isbn: Value(book.isbn),
        publisher: Value(book.publisher),
        publishDate: Value(book.publishDate),
        language: Value(book.language),
        readingTime: Value(book.readingTime),
      );

      await database.insertBook(bookData);
      developer.log(
        'Book added successfully: ${book.title}',
        name: 'DatabaseService',
      );
      return true;
    } catch (ex) {
      developer.log('Error adding book: $ex', name: 'DatabaseService');
      return false;
    }
  }

  static Future<bool> deleteBook(String id) async {
    try {
      await database.deleteBook(id);
      developer.log('Book deleted successfully: $id', name: 'DatabaseService');
      return true;
    } catch (ex) {
      developer.log('Error deleting book: $ex', name: 'DatabaseService');
      return false;
    }
  }

  static Future<Book?> getBook(String id) async {
    try {
      final bookData = await database.getBook(id);
      if (bookData != null) {
        return _convertToBook(bookData);
      }
      return null;
    } catch (ex) {
      developer.log('Error getting book: $ex', name: 'DatabaseService');
      return null;
    }
  }

  static Future<List<Book>> getAllBooks() async {
    try {
      final booksData = await database.getAllBooks();
      return booksData.map((bookData) => _convertToBook(bookData)).toList();
    } catch (ex) {
      developer.log('Error getting all books: $ex', name: 'DatabaseService');
      return [];
    }
  }

  static Future<List<Book>> getFavoriteBooks() async {
    try {
      final booksData = await database.getFavoriteBooks();
      return booksData.map((bookData) => _convertToBook(bookData)).toList();
    } catch (ex) {
      developer.log(
        'Error getting favorite books: $ex',
        name: 'DatabaseService',
      );
      return [];
    }
  }

  static Future<List<Book>> getRecentlyReadBooks({int limit = 10}) async {
    try {
      final booksData = await database.getRecentlyReadBooks(limit: limit);
      return booksData.map((bookData) => _convertToBook(bookData)).toList();
    } catch (ex) {
      developer.log(
        'Error getting recently read books: $ex',
        name: 'DatabaseService',
      );
      return [];
    }
  }

  static Future<bool> updateFavorite(String id) async {
    try {
      final book = await getBook(id);
      if (book != null) {
        final newFavoriteValue = book.isFavorite == 1 ? 0 : 1;
        await database.updateBook(
          db.BooksCompanion(id: Value(id), isFavorite: Value(newFavoriteValue)),
        );
        developer.log('Book favorite updated: $id', name: 'DatabaseService');
        return true;
      }
      return false;
    } catch (ex) {
      developer.log('Error updating favorite: $ex', name: 'DatabaseService');
      return false;
    }
  }

  static Future<bool> updateLastRead(String id) async {
    try {
      await database.updateLastRead(id);
      developer.log('Book last read updated: $id', name: 'DatabaseService');
      return true;
    } catch (ex) {
      developer.log('Error updating last read: $ex', name: 'DatabaseService');
      return false;
    }
  }

  static Future<bool> updateLastReadLocator(String id, String locator) async {
    try {
      await database.updateLastReadLocator(id, locator);
      developer.log('Book locator updated: $id', name: 'DatabaseService');
      return true;
    } catch (ex) {
      developer.log('Error updating locator: $ex', name: 'DatabaseService');
      return false;
    }
  }

  static Future<bool> updateReadingProgress(
    String id,
    int currentPage,
    double progressPercent,
  ) async {
    try {
      await database.updateReadingProgress(id, currentPage, progressPercent);
      developer.log('Reading progress updated: $id', name: 'DatabaseService');
      return true;
    } catch (ex) {
      developer.log(
        'Error updating reading progress: $ex',
        name: 'DatabaseService',
      );
      return false;
    }
  }

  // Reading session operations
  static Future<int> startReadingSession(String bookId) async {
    try {
      final session = db.ReadingSessionsCompanion.insert(
        bookId: bookId,
        startTime: DateTime.now(),
        pagesRead: 0,
        durationMinutes: 0,
      );
      final sessionId = await database.insertReadingSession(session);
      developer.log(
        'Reading session started: $sessionId',
        name: 'DatabaseService',
      );
      return sessionId;
    } catch (ex) {
      developer.log(
        'Error starting reading session: $ex',
        name: 'DatabaseService',
      );
      return -1;
    }
  }

  static Future<bool> endReadingSession(
    int sessionId,
    int pagesRead,
    int durationMinutes,
  ) async {
    try {
      await database.endReadingSession(
        sessionId,
        DateTime.now(),
        pagesRead,
        durationMinutes,
      );
      developer.log(
        'Reading session ended: $sessionId',
        name: 'DatabaseService',
      );
      return true;
    } catch (ex) {
      developer.log(
        'Error ending reading session: $ex',
        name: 'DatabaseService',
      );
      return false;
    }
  }

  // Bookmark operations
  static Future<int> addBookmark(
    String bookId,
    String title,
    String locator, {
    String? notes,
    int? pageNumber,
  }) async {
    try {
      final bookmark = db.BookmarksCompanion.insert(
        bookId: bookId,
        title: title,
        locator: locator,
        createdAt: DateTime.now(),
        notes: Value(notes),
        pageNumber: Value(pageNumber),
      );
      final bookmarkId = await database.insertBookmark(bookmark);
      developer.log('Bookmark added: $bookmarkId', name: 'DatabaseService');
      return bookmarkId;
    } catch (ex) {
      developer.log('Error adding bookmark: $ex', name: 'DatabaseService');
      return -1;
    }
  }

  static Future<List<Map<String, dynamic>>> getBookmarks(String bookId) async {
    try {
      final bookmarks = await database.getBookmarks(bookId);
      return bookmarks
          .map(
            (bookmark) => {
              'id': bookmark.id,
              'bookId': bookmark.bookId,
              'title': bookmark.title,
              'locator': bookmark.locator,
              'createdAt': bookmark.createdAt.toIso8601String(),
              'notes': bookmark.notes,
              'pageNumber': bookmark.pageNumber,
            },
          )
          .toList();
    } catch (ex) {
      developer.log('Error getting bookmarks: $ex', name: 'DatabaseService');
      return [];
    }
  }

  static Future<bool> deleteBookmark(int bookmarkId) async {
    try {
      await database.deleteBookmark(bookmarkId);
      developer.log('Bookmark deleted: $bookmarkId', name: 'DatabaseService');
      return true;
    } catch (ex) {
      developer.log('Error deleting bookmark: $ex', name: 'DatabaseService');
      return false;
    }
  }

  // Search operations
  static Future<List<Book>> searchBooks(String query) async {
    try {
      final booksData = await database.searchBooks(query);
      return booksData.map((bookData) => _convertToBook(bookData)).toList();
    } catch (ex) {
      developer.log('Error searching books: $ex', name: 'DatabaseService');
      return [];
    }
  }

  // Statistics
  static Future<int> getTotalBooks() async {
    try {
      return await database.getTotalBooks();
    } catch (ex) {
      developer.log('Error getting total books: $ex', name: 'DatabaseService');
      return 0;
    }
  }

  static Future<int> getTotalReadingTime() async {
    try {
      return await database.getTotalReadingTime();
    } catch (ex) {
      developer.log(
        'Error getting total reading time: $ex',
        name: 'DatabaseService',
      );
      return 0;
    }
  }

  static Future<List<Book>> getMostReadBooks({int limit = 10}) async {
    try {
      final booksData = await database.getMostReadBooks(limit: limit);
      return booksData.map((bookData) => _convertToBook(bookData)).toList();
    } catch (ex) {
      developer.log(
        'Error getting most read books: $ex',
        name: 'DatabaseService',
      );
      return [];
    }
  }

  // Helper method to convert Drift Book data to our Book model
  static Book _convertToBook(db.Book bookData) {
    return Book(
      id: bookData.id,
      title: bookData.title,
      author: bookData.author,
      lastRead: bookData.lastRead,
      addedDate: bookData.addedDate,
      isFavorite: bookData.isFavorite,
      filePath: bookData.filePath,
      fileType: bookData.fileType,
      fileSize: bookData.fileSize,
      lastReadLocator: bookData.lastReadLocator,
      coverImageData: bookData.coverImageData.toList(),
      totalPages: bookData.totalPages,
      currentPage: bookData.currentPage,
      progressPercent: bookData.progressPercent,
      description: bookData.description,
      isbn: bookData.isbn,
      publisher: bookData.publisher,
      publishDate: bookData.publishDate,
      language: bookData.language,
      readingTime: bookData.readingTime,
    );
  }
}
