import 'package:arcana_ebook_reader/dto/BookDtos.dart';
import 'package:arcana_ebook_reader/extension.dart';

class BookUtils {
  /// Sort books by title in ascending or descending order
  static List<BookDto> sortByTitle(
    List<BookDto> books, {
    bool ascending = true,
  }) {
    final sorted = List<BookDto>.from(books);
    if (ascending) {
      sorted.sort((a, b) => a.title.compareTo(b.title));
    } else {
      sorted.sort((a, b) => b.title.compareTo(a.title));
    }
    return sorted;
  }

  /// Sort books by last read date
  static List<BookDto> sortByLastRead(List<BookDto> books) {
    final sorted = List<BookDto>.from(books);
    sorted.sort((a, b) => b.lastRead.compareToWithNull(a.lastRead));
    return sorted;
  }

  /// Sort books by added date
  static List<BookDto> sortByAddedDate(List<BookDto> books) {
    final sorted = List<BookDto>.from(books);
    sorted.sort((a, b) => b.addedDate.compareTo(a.addedDate));
    return sorted;
  }

  /// Filter books by favorite status
  static List<BookDto> filterFavorites(List<BookDto> books) {
    return books.where((book) => book.isFavorite == 1).toList();
  }

  /// Get recently read books
  static List<BookDto> getRecentlyRead(List<BookDto> books) {
    return books.where((book) => book.lastRead != null).toList();
  }

  /// Get the most recently read book
  static BookDto? getMostRecentlyRead(List<BookDto> books) {
    final recentlyRead = getRecentlyRead(books);
    if (recentlyRead.isEmpty) return null;

    final sorted = sortByLastRead(recentlyRead);
    return sorted.first;
  }

  /// Get recent books (limited count)
  static List<BookDto> getRecentBooks(List<BookDto> books, {int limit = 7}) {
    final sorted = sortByAddedDate(books);
    return sorted.take(limit).toList();
  }

  /// Search books by title or author
  static List<BookDto> searchBooks(List<BookDto> books, String query) {
    if (query.isEmpty) return books;

    final lowercaseQuery = query.toLowerCase();
    return books.where((book) {
      return book.title.toLowerCase().contains(lowercaseQuery) ||
          book.author.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
