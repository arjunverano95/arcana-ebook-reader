import 'package:arcana_ebook_reader/models/Book.dart';

class BookUtils {
  static List<Book> sortBooksByTitle(
    List<Book> books, {
    bool ascending = true,
  }) {
    List<Book> sortedBooks = List.from(books);
    if (ascending) {
      sortedBooks.sort((a, b) => a.title.compareTo(b.title));
    } else {
      sortedBooks.sort((a, b) => b.title.compareTo(a.title));
    }
    return sortedBooks;
  }

  static List<Book> sortBooksByAuthor(
    List<Book> books, {
    bool ascending = true,
  }) {
    List<Book> sortedBooks = List.from(books);
    if (ascending) {
      sortedBooks.sort((a, b) => a.author.compareTo(b.author));
    } else {
      sortedBooks.sort((a, b) => b.author.compareTo(a.author));
    }
    return sortedBooks;
  }

  static List<Book> sortBooksByLastRead(
    List<Book> books, {
    bool ascending = true,
  }) {
    List<Book> sortedBooks = List.from(books);
    if (ascending) {
      sortedBooks.sort((a, b) {
        if (a.lastRead == null && b.lastRead == null) return 0;
        if (a.lastRead == null) return 1;
        if (b.lastRead == null) return -1;
        return a.lastRead!.compareTo(b.lastRead!);
      });
    } else {
      sortedBooks.sort((a, b) {
        if (a.lastRead == null && b.lastRead == null) return 0;
        if (a.lastRead == null) return 1;
        if (b.lastRead == null) return -1;
        return b.lastRead!.compareTo(a.lastRead!);
      });
    }
    return sortedBooks;
  }

  static List<Book> sortBooksByAddedDate(
    List<Book> books, {
    bool ascending = true,
  }) {
    List<Book> sortedBooks = List.from(books);
    if (ascending) {
      sortedBooks.sort((a, b) => a.addedDate.compareTo(b.addedDate));
    } else {
      sortedBooks.sort((a, b) => b.addedDate.compareTo(a.addedDate));
    }
    return sortedBooks;
  }

  static List<Book> sortBooksByFavorite(List<Book> books) {
    List<Book> sortedBooks = List.from(books);
    sortedBooks.sort((a, b) => b.isFavorite.compareTo(a.isFavorite));
    return sortedBooks;
  }

  static List<Book> filterBooksByTitle(List<Book> books, String query) {
    return books
        .where(
          (book) =>
              book.title.toLowerCase().contains(query.toLowerCase()) ||
              book.author.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  static List<Book> filterBooksByAuthor(List<Book> books, String author) {
    return books
        .where(
          (book) => book.author.toLowerCase().contains(author.toLowerCase()),
        )
        .toList();
  }

  static List<Book> filterBooksByFileType(List<Book> books, String fileType) {
    return books
        .where((book) => book.fileType.toLowerCase() == fileType.toLowerCase())
        .toList();
  }

  static List<Book> getFavoriteBooks(List<Book> books) {
    return books.where((book) => book.isFavorite == 1).toList();
  }

  static List<Book> getRecentlyReadBooks(List<Book> books, {int limit = 10}) {
    List<Book> recentlyRead = books
        .where((book) => book.lastRead != null)
        .toList();
    recentlyRead.sort((a, b) => b.lastRead!.compareTo(a.lastRead!));
    return recentlyRead.take(limit).toList();
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  static bool isSupportedFileType(String filePath) {
    String extension = getFileExtension(filePath);
    return ['epub', 'pdf', 'mobi', 'txt'].contains(extension);
  }
}
