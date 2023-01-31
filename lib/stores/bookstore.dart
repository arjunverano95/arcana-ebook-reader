import 'package:mobx/mobx.dart';

import 'package:arcana_ebook_reader/dto/BookDtos.dart';
import 'package:arcana_ebook_reader/util/bookLibrary.dart';

part 'bookstore.g.dart';

class Bookstore = BookstoreBase with _$Bookstore;

abstract class BookstoreBase with Store {
  @observable
  List<BookDto> books = [];

  @action
  Future<void> getBooks() async {
    var newBooks = await BookLibrary.getAll();

    List<BookDto> oldBooks = List.from(books);
    final lookup = {for (var m in oldBooks) m.id: m};

    newBooks = newBooks.map((book) {
      var oldBook = lookup[book.id];
      if (oldBook != null) book.coverImageData = oldBook.coverImageData;
      return book;
    }).toList();

    books = newBooks;
  }
}
// flutter packages pub run build_runner build
