import 'package:mobx/mobx.dart';

import 'package:arcana_ebook_reader/models/Book.dart';
import 'package:arcana_ebook_reader/services/database_service.dart';

part 'bookstore.g.dart';

class Bookstore = BookstoreBase with _$Bookstore;

abstract class BookstoreBase with Store {
  @observable
  List<Book> books = [];

  @observable
  List<Book> favoriteBooks = [];

  @observable
  List<Book> recentlyReadBooks = [];

  @observable
  bool isLoading = false;

  @action
  Future<void> getBooks() async {
    isLoading = true;
    try {
      var newBooks = await DatabaseService.getAllBooks();
      books = newBooks;
    } catch (e) {
      // Handle error
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> getFavoriteBooks() async {
    try {
      favoriteBooks = await DatabaseService.getFavoriteBooks();
    } catch (e) {
      // Handle error
    }
  }

  @action
  Future<void> getRecentlyReadBooks() async {
    try {
      recentlyReadBooks = await DatabaseService.getRecentlyReadBooks();
    } catch (e) {
      // Handle error
    }
  }

  @action
  Future<bool> addBook(Book book) async {
    try {
      final success = await DatabaseService.addBook(book);
      if (success) {
        await getBooks();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  @action
  Future<bool> deleteBook(String id) async {
    try {
      final success = await DatabaseService.deleteBook(id);
      if (success) {
        await getBooks();
        await getFavoriteBooks();
        await getRecentlyReadBooks();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  @action
  Future<bool> toggleFavorite(String id) async {
    try {
      final success = await DatabaseService.updateFavorite(id);
      if (success) {
        await getBooks();
        await getFavoriteBooks();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  @action
  Future<bool> updateLastRead(String id) async {
    try {
      final success = await DatabaseService.updateLastRead(id);
      if (success) {
        await getRecentlyReadBooks();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  @action
  Future<bool> updateLastReadLocator(String id, String locator) async {
    try {
      return await DatabaseService.updateLastReadLocator(id, locator);
    } catch (e) {
      return false;
    }
  }

  @action
  Future<bool> updateReadingProgress(
    String id,
    int currentPage,
    double progressPercent,
  ) async {
    try {
      final success = await DatabaseService.updateReadingProgress(
        id,
        currentPage,
        progressPercent,
      );
      if (success) {
        await getBooks();
        await getRecentlyReadBooks();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  @action
  Future<List<Book>> searchBooks(String query) async {
    try {
      return await DatabaseService.searchBooks(query);
    } catch (e) {
      return [];
    }
  }

  @action
  Future<void> refreshAll() async {
    await Future.wait([getBooks(), getFavoriteBooks(), getRecentlyReadBooks()]);
  }
}
